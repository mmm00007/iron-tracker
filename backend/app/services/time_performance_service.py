"""Time-of-day performance analysis.

Circadian rhythms influence strength output, with most individuals showing
peak force production in the late afternoon (Grgic et al. 2019, Sports Med).
This service buckets training into four time windows and computes descriptive
statistics so users can see when they tend to perform best. No inferential
testing (ANOVA) is applied — the sample sizes per bin are typically too small
and the confounders too many for causal claims.
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    TimePerformanceResponse,
    TimeWindowEntry,
)

# ─── Time Windows ─────────────────────────────────────────────────────────────

WINDOW_RANGES = {
    "morning": "5:00 - 11:59",
    "afternoon": "12:00 - 16:59",
    "evening": "17:00 - 20:59",
    "night": "21:00 - 4:59",
}

_WINDOW_ORDER = ["morning", "afternoon", "evening", "night"]

_MIN_SESSIONS = 5  # minimum sessions per window to report


def _get_window(hour: int) -> str:
    if 5 <= hour <= 11:
        return "morning"
    if 12 <= hour <= 16:
        return "afternoon"
    if 17 <= hour <= 20:
        return "evening"
    return "night"  # 21-4


_DISCLAIMER = (
    "Performance varies throughout the day due to circadian rhythms, "
    "nutrition, and other factors. Training at any time is beneficial "
    "— consistency matters more than optimal timing."
)


# ─── Service ──────────────────────────────────────────────────────────────────


async def compute_time_performance(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> TimePerformanceResponse:
    """Analyse performance across four time-of-day windows.

    Returns per-window averages for e1RM (as % of best), volume, RPE and
    session count, plus the best-performing window and its advantage over
    the second-best.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        # 1. Resolve user timezone
        tz_row = await conn.fetchrow(
            "SELECT COALESCE(timezone, 'UTC') AS timezone "
            "FROM profiles WHERE id = $1",
            user_id,
        )
        user_tz = tz_row["timezone"] if tz_row else "UTC"

        # 2. Hourly aggregates
        rows = await conn.fetch(
            """
            SELECT
                EXTRACT(HOUR FROM (s.logged_at AT TIME ZONE $2))::int AS hour_of_day,
                COUNT(DISTINCT DATE(s.logged_at AT TIME ZONE $2)) AS session_count,
                AVG(s.estimated_1rm)
                    FILTER (WHERE s.set_type = 'working' AND s.estimated_1rm > 0)
                    AS avg_e1rm,
                SUM(
                    CASE WHEN s.weight_unit = 'lb'
                         THEN s.weight * 0.453592
                         ELSE s.weight
                    END * s.reps
                ) AS total_volume_kg,
                COUNT(*) FILTER (WHERE s.set_type = 'working') AS working_sets,
                AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL) AS avg_rpe
            FROM sets s
            WHERE s.user_id = $1
              AND s.logged_at >= $3
              AND s.reps > 0
            GROUP BY EXTRACT(HOUR FROM (s.logged_at AT TIME ZONE $2))
            ORDER BY hour_of_day
            """,
            user_id,
            user_tz,
            since,
        )

    # ── Bucket hourly rows into windows ───────────────────────────────────

    # Accumulate per-window totals
    window_data: dict[str, dict] = {
        w: {
            "session_count": 0,
            "e1rm_sum": 0.0,
            "e1rm_count": 0,
            "total_volume_kg": 0.0,
            "working_sets": 0,
            "rpe_sum": 0.0,
            "rpe_count": 0,
        }
        for w in _WINDOW_ORDER
    }

    for row in rows:
        window = _get_window(row["hour_of_day"])
        wd = window_data[window]
        wd["session_count"] += row["session_count"]
        wd["total_volume_kg"] += float(row["total_volume_kg"] or 0)
        wd["working_sets"] += row["working_sets"]
        if row["avg_e1rm"] is not None:
            wd["e1rm_sum"] += float(row["avg_e1rm"]) * row["working_sets"]
            wd["e1rm_count"] += row["working_sets"]
        if row["avg_rpe"] is not None:
            wd["rpe_sum"] += float(row["avg_rpe"]) * row["working_sets"]
            wd["rpe_count"] += row["working_sets"]

    # Compute per-window averages
    avg_e1rms: dict[str, float | None] = {}
    for w in _WINDOW_ORDER:
        wd = window_data[w]
        if wd["session_count"] >= _MIN_SESSIONS and wd["e1rm_count"] > 0:
            avg_e1rms[w] = wd["e1rm_sum"] / wd["e1rm_count"]
        else:
            avg_e1rms[w] = None

    # Best e1RM across qualifying windows (for %-of-best calculation)
    qualifying_e1rms = {w: v for w, v in avg_e1rms.items() if v is not None}
    best_e1rm = max(qualifying_e1rms.values()) if qualifying_e1rms else None

    # Build response entries
    windows: list[TimeWindowEntry] = []
    for w in _WINDOW_ORDER:
        wd = window_data[w]
        if wd["session_count"] < _MIN_SESSIONS:
            # Still include the window but with None metrics
            windows.append(
                TimeWindowEntry(
                    window=w,
                    hour_range=WINDOW_RANGES[w],
                    session_count=wd["session_count"],
                    avg_e1rm_pct=None,
                    avg_volume_kg=0.0,
                    avg_rpe=None,
                    working_sets=wd["working_sets"],
                )
            )
            continue

        avg_e1rm_pct: float | None = None
        if avg_e1rms[w] is not None and best_e1rm:
            avg_e1rm_pct = round((avg_e1rms[w] / best_e1rm) * 100, 1)

        avg_rpe: float | None = None
        if wd["rpe_count"] > 0:
            avg_rpe = round(wd["rpe_sum"] / wd["rpe_count"], 1)

        avg_volume = round(wd["total_volume_kg"] / wd["session_count"], 1)

        windows.append(
            TimeWindowEntry(
                window=w,
                hour_range=WINDOW_RANGES[w],
                session_count=wd["session_count"],
                avg_e1rm_pct=avg_e1rm_pct,
                avg_volume_kg=avg_volume,
                avg_rpe=avg_rpe,
                working_sets=wd["working_sets"],
            )
        )

    # ── Best window & advantage ───────────────────────────────────────────

    best_window: str | None = None
    best_window_advantage_pct: float | None = None

    if qualifying_e1rms:
        sorted_windows = sorted(
            qualifying_e1rms.items(), key=lambda x: x[1], reverse=True
        )
        best_window = sorted_windows[0][0]
        if len(sorted_windows) >= 2:
            second_best_e1rm = sorted_windows[1][1]
            if second_best_e1rm > 0:
                best_window_advantage_pct = round(
                    ((sorted_windows[0][1] / second_best_e1rm) - 1) * 100, 1
                )

    # ── Data coverage ─────────────────────────────────────────────────────

    qualifying_count = len(qualifying_e1rms)
    if qualifying_count >= 4:
        data_coverage = "comprehensive"
    elif qualifying_count == 3:
        data_coverage = "good"
    elif qualifying_count == 2:
        data_coverage = "limited"
    elif qualifying_count == 1:
        data_coverage = "single_window"
    else:
        data_coverage = "single_window"

    return TimePerformanceResponse(
        windows=windows,
        best_window=best_window,
        best_window_advantage_pct=best_window_advantage_pct,
        data_coverage=data_coverage,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

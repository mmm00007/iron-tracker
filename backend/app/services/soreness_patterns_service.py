"""Soreness pattern analysis: per-muscle trends, red flags, and volume correlation."""

from datetime import UTC, datetime, timedelta
from typing import Any

import asyncpg

from app.models.schemas import MuscleSorenessEntry, SorenessPatternsResponse

# ─── Constants ────────────────────────────────────────────────────────────────

# Minimum reports before we return meaningful analysis.
MIN_REPORTS = 3

# Minimum matched (volume, soreness) data points for Spearman correlation.
MIN_CORRELATION_POINTS = 8

# Trend threshold: difference in average level between halves to be non-stable.
TREND_THRESHOLD = 0.3

DISCLAIMER = (
    "Soreness (DOMS) is a normal response to training and does not reliably "
    "indicate muscle damage or growth. This app does not distinguish DOMS from "
    "pathological pain. Persistent severe soreness may warrant medical evaluation."
)

# ─── SQL Queries ──────────────────────────────────────────────────────────────

_SORENESS_QUERY = """\
SELECT
    sr.muscle_group_id,
    mg.name AS muscle_group_name,
    sr.level,
    sr.training_date,
    sr.reported_at,
    EXTRACT(EPOCH FROM sr.reported_at - sr.training_date::timestamptz) / 3600 AS lag_hours
FROM soreness_reports sr
JOIN muscle_groups mg ON mg.id = sr.muscle_group_id
WHERE sr.user_id = $1
  AND sr.training_date >= $2
ORDER BY sr.training_date DESC
"""

_VOLUME_QUERY = """\
SELECT
    s.training_date,
    SUM(
        CASE WHEN s.weight_unit = 'lb'
             THEN s.weight * 0.453592
             ELSE s.weight END * s.reps
    ) AS volume_kg
FROM sets s
WHERE s.user_id = $1
  AND s.training_date >= $2
  AND s.reps > 0
GROUP BY s.training_date
"""

# ─── Spearman rank correlation (pure Python) ──────────────────────────────────


def _rank(values: list[float]) -> list[float]:
    """Assign ranks to values (1-based, no tie correction)."""
    sorted_indices = sorted(range(len(values)), key=lambda i: values[i])
    ranks = [0.0] * len(values)
    for rank, idx in enumerate(sorted_indices, 1):
        ranks[idx] = float(rank)
    return ranks


def _spearman(xs: list[float], ys: list[float]) -> float | None:
    """Compute Spearman rank correlation coefficient.

    Returns None if fewer than MIN_CORRELATION_POINTS data points.
    """
    if len(xs) < MIN_CORRELATION_POINTS or len(xs) != len(ys):
        return None
    rx, ry = _rank(xs), _rank(ys)
    n = len(rx)
    mx = sum(rx) / n
    my = sum(ry) / n
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    if dx == 0 or dy == 0:
        return 0.0
    return float(round(num / (dx * dy), 3))


# ─── Trend detection ─────────────────────────────────────────────────────────


def _compute_trend(levels: list[float], dates: list[Any], period_midpoint: Any) -> str:
    """Compare average level from first half vs second half of the period.

    Returns 'worsening', 'improving', or 'stable'.
    """
    if len(levels) < 2:
        return "stable"

    first_half = [lv for lv, d in zip(levels, dates) if d < period_midpoint]
    second_half = [lv for lv, d in zip(levels, dates) if d >= period_midpoint]

    if not first_half or not second_half:
        return "stable"

    first_avg = sum(first_half) / len(first_half)
    second_avg = sum(second_half) / len(second_half)

    if second_avg > first_avg + TREND_THRESHOLD:
        return "worsening"
    if first_avg > second_avg + TREND_THRESHOLD:
        return "improving"
    return "stable"


# ─── Red flag detection ──────────────────────────────────────────────────────


def _detect_red_flags(
    muscle_reports: dict[str, list[dict[str, Any]]],
    muscle_names: dict[int, str],
) -> list[str]:
    """Detect red flags in soreness data.

    Two categories:
    1. Level 4 persisting >72h (lag_hours from training_date to reported_at)
    2. Escalating pattern: 3+ consecutive reports with increasing level
    """
    red_flags: list[str] = []
    seen_flags: set[str] = set()

    for muscle_id_str, reports in muscle_reports.items():
        muscle_id = int(muscle_id_str)
        name = muscle_names.get(muscle_id, f"muscle_{muscle_id}")

        # Level 4 persisting >72h
        for r in reports:
            if r["level"] >= 4 and r["lag_hours"] is not None and r["lag_hours"] > 72:
                flag = f"Severe soreness in {name} persisting >72 hours"
                if flag not in seen_flags:
                    red_flags.append(flag)
                    seen_flags.add(flag)
                break

        # Escalating pattern (3+ consecutive increasing reports for same muscle)
        sorted_reports = sorted(reports, key=lambda r: r["training_date"])
        for i in range(len(sorted_reports) - 2):
            if (
                sorted_reports[i]["level"]
                < sorted_reports[i + 1]["level"]
                < sorted_reports[i + 2]["level"]
            ):
                flag = f"Escalating soreness pattern in {name}"
                if flag not in seen_flags:
                    red_flags.append(flag)
                    seen_flags.add(flag)
                break

    return red_flags


# ─── Main service function ────────────────────────────────────────────────────


async def compute_soreness_patterns(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> SorenessPatternsResponse:
    """Analyse soreness patterns: per-muscle stats, trends, red flags, and
    volume-soreness correlation.

    Cold start: requires >= 3 soreness reports. For volume-soreness correlation,
    requires >= 8 matched data points.
    """
    cutoff = (datetime.now(UTC) - timedelta(days=period_days)).date()
    period_midpoint = cutoff + timedelta(days=period_days // 2)

    async with db_pool.acquire() as conn:
        soreness_rows = await conn.fetch(_SORENESS_QUERY, user_id, cutoff)
        volume_rows = await conn.fetch(_VOLUME_QUERY, user_id, cutoff)

    n = len(soreness_rows)

    # ── Insufficient data ─────────────────────────────────────────────────
    if n < MIN_REPORTS:
        return SorenessPatternsResponse(
            muscles=[],
            overall_avg_level=None,
            most_sore_muscle=None,
            red_flags=[],
            correlation_volume_soreness=None,
            data_points=n,
            period_days=period_days,
            disclaimer=DISCLAIMER,
        )

    # ── Group soreness data by muscle ─────────────────────────────────────
    # muscle_id -> list of report dicts
    muscle_reports: dict[str, list[dict[str, Any]]] = {}
    muscle_names: dict[int, str] = {}

    for row in soreness_rows:
        mid = row["muscle_group_id"]
        muscle_names[mid] = row["muscle_group_name"]
        key = str(mid)
        if key not in muscle_reports:
            muscle_reports[key] = []
        muscle_reports[key].append(
            {
                "level": int(row["level"]),
                "training_date": row["training_date"],
                "reported_at": row["reported_at"],
                "lag_hours": float(row["lag_hours"]) if row["lag_hours"] is not None else None,
            }
        )

    # ── Per-muscle aggregation ────────────────────────────────────────────
    entries: list[MuscleSorenessEntry] = []
    all_levels: list[float] = []

    for muscle_id_str, reports in sorted(muscle_reports.items(), key=lambda x: x[0]):
        mid = int(muscle_id_str)
        name = muscle_names[mid]

        levels = [float(r["level"]) for r in reports]
        lag_hours_list = [r["lag_hours"] for r in reports if r["lag_hours"] is not None]
        dates = [r["training_date"] for r in reports]

        avg_level = round(sum(levels) / len(levels), 2)
        max_level = int(max(levels))
        report_count = len(reports)
        avg_lag = round(sum(lag_hours_list) / len(lag_hours_list), 1) if lag_hours_list else None
        trend = _compute_trend(levels, dates, period_midpoint)

        all_levels.extend(levels)

        entries.append(
            MuscleSorenessEntry(
                muscle_group=name,
                avg_level=avg_level,
                max_level=max_level,
                report_count=report_count,
                avg_lag_hours=avg_lag,
                trend=trend,
            )
        )

    # Sort by avg_level descending (most sore first)
    entries.sort(key=lambda e: e.avg_level, reverse=True)

    overall_avg = round(sum(all_levels) / len(all_levels), 2) if all_levels else None
    most_sore = entries[0].muscle_group if entries else None

    # ── Red flag detection ────────────────────────────────────────────────
    red_flags = _detect_red_flags(muscle_reports, muscle_names)

    # ── Volume-soreness correlation ───────────────────────────────────────
    # Build a map of training_date -> total volume
    volume_by_date: dict[Any, float] = {}
    for row in volume_rows:
        td = row["training_date"]
        vol = float(row["volume_kg"]) if row["volume_kg"] is not None else 0.0
        volume_by_date[td] = vol

    # Build a map of training_date -> max soreness level
    soreness_by_date: dict[Any, int] = {}
    for row in soreness_rows:
        td = row["training_date"]
        level = int(row["level"])
        if td not in soreness_by_date or level > soreness_by_date[td]:
            soreness_by_date[td] = level

    # Match dates that appear in both
    matched_volumes: list[float] = []
    matched_soreness: list[float] = []
    for td in sorted(volume_by_date.keys()):
        if td in soreness_by_date:
            matched_volumes.append(volume_by_date[td])
            matched_soreness.append(float(soreness_by_date[td]))

    correlation = _spearman(matched_volumes, matched_soreness)

    return SorenessPatternsResponse(
        muscles=entries,
        overall_avg_level=overall_avg,
        most_sore_muscle=most_sore,
        red_flags=red_flags,
        correlation_volume_soreness=correlation,
        data_points=n,
        period_days=period_days,
        disclaimer=DISCLAIMER,
    )

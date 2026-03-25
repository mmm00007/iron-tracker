"""Mesocycle effectiveness analysis: phase alignment, e1RM progression, volume tracking.

Evaluates how well each mesocycle's actual training matched its declared phase
and identifies which phases produced the best strength gains. Uses a simplified
heuristic based on RPE and volume trends rather than cosine similarity.

Cold start: requires at least 1 mesocycle with >= 2 weeks of training data.
"""

from collections import defaultdict
from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import MesocycleEffectivenessResponse, MesocycleEntry

# ─── Phase ideal profiles ────────────────────────────────────────────────────

_PHASE_IDEAL: dict[str, dict | None] = {
    "hypertrophy": {"rpe_range": (6, 8), "volume_trend": "high"},
    "strength": {"rpe_range": (7, 9.5), "volume_trend": "moderate"},
    "peaking": {"rpe_range": (8, 10), "volume_trend": "low"},
    "deload": {"rpe_range": (4, 7), "volume_trend": "very_low"},
    "general": None,  # no alignment check
    "transition": None,
}

_VOLUME_THRESHOLDS: dict[str, tuple[float, float]] = {
    "high": (0.7, 1.0),
    "moderate": (0.4, 0.7),
    "low": (0.15, 0.4),
    "very_low": (0.0, 0.15),
}


# ─── Helpers ──────────────────────────────────────────────────────────────────


def _alignment_score(phase: str, avg_rpe: float | None, volume_pct_of_max: float) -> float | None:
    """Compute phase alignment score (0-100) from RPE and volume profile.

    Returns None for phases without an ideal profile (general, transition).
    """
    ideal = _PHASE_IDEAL.get(phase)
    if ideal is None:
        return None

    score = 0.0

    # RPE alignment (0-50 points)
    rpe_val = avg_rpe or 0.0
    rpe_lo, rpe_hi = ideal["rpe_range"]
    if rpe_lo <= rpe_val <= rpe_hi:
        score += 50.0
    else:
        distance = min(abs(rpe_val - rpe_lo), abs(rpe_val - rpe_hi))
        score += max(0.0, 50.0 - distance * 15.0)

    # Volume alignment (0-50 points)
    vol_trend: str = ideal["volume_trend"]
    vol_lo, vol_hi = _VOLUME_THRESHOLDS[vol_trend]
    if vol_lo <= volume_pct_of_max <= vol_hi:
        score += 50.0
    else:
        distance = min(abs(volume_pct_of_max - vol_lo), abs(volume_pct_of_max - vol_hi))
        score += max(0.0, 50.0 - distance * 100.0)

    return round(score, 1)


def _e1rm_change_pct(
    weekly_e1rms: dict[int, float],
) -> float | None:
    """Compute e1RM change from first 2 weeks to last 2 weeks.

    Returns percentage change, or None if insufficient data.
    """
    if not weekly_e1rms:
        return None

    sorted_weeks = sorted(weekly_e1rms.keys())
    if len(sorted_weeks) < 2:
        return None

    # First 2 weeks
    first_weeks = sorted_weeks[:2]
    first_max = max(weekly_e1rms[w] for w in first_weeks)

    # Last 2 weeks
    last_weeks = sorted_weeks[-2:]
    last_max = max(weekly_e1rms[w] for w in last_weeks)

    if first_max <= 0:
        return None

    return round((last_max - first_max) / first_max * 100, 1)


# ─── Main computation ────────────────────────────────────────────────────────


async def compute_mesocycle_effectiveness(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 365,
) -> MesocycleEffectivenessResponse:
    """Analyze effectiveness of mesocycles over the given period.

    For each mesocycle with overlapping training data:
    - Counts weeks completed based on distinct training weeks
    - Computes total volume and average RPE
    - Measures e1RM change from first 2 weeks to last 2 weeks
    - Scores phase alignment against ideal RPE/volume profiles
    - Identifies the best phase for strength gains
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT m.id::text AS mesocycle_id, m.name, m.phase,
                   m.start_date::text, m.end_date::text, m.target_weeks,
                   tds.training_date, tds.total_sets, tds.working_sets,
                   tds.total_volume_kg::float, tds.avg_rpe::float,
                   (SELECT MAX(estimated_1rm) FROM sets WHERE user_id = $1
                    AND training_date = tds.training_date AND estimated_1rm > 0) AS best_e1rm
            FROM mesocycles m
            JOIN training_day_summary tds ON tds.user_id = m.user_id
              AND tds.training_date BETWEEN m.start_date AND COALESCE(m.end_date, CURRENT_DATE)
            WHERE m.user_id = $1 AND m.start_date >= $2
            ORDER BY m.start_date DESC, tds.training_date
            """,
            user_id,
            since,
        )

    if not rows:
        return MesocycleEffectivenessResponse(
            mesocycles=[],
            total_mesocycles=0,
            current_phase=None,
            best_phase_for_strength=None,
            period_days=period_days,
            disclaimer=(
                "Mesocycle effectiveness reflects observed patterns in your training data. "
                "Phase alignment is an estimate based on volume and intensity — "
                "individual programming may vary."
            ),
        )

    # ── Group rows by mesocycle ───────────────────────────────────────────────

    meso_data: dict[str, dict] = {}
    for row in rows:
        mid = row["mesocycle_id"]
        if mid not in meso_data:
            meso_data[mid] = {
                "name": row["name"],
                "phase": row["phase"] or "general",
                "start_date": row["start_date"],
                "end_date": row["end_date"],
                "target_weeks": row["target_weeks"],
                "volumes": [],
                "rpes": [],
                "training_dates": set(),
                "weekly_e1rms": {},
            }
        d = meso_data[mid]
        training_date = row["training_date"]
        d["training_dates"].add(training_date)

        vol = row["total_volume_kg"]
        if vol is not None and vol > 0:
            d["volumes"].append(vol)

        rpe = row["avg_rpe"]
        if rpe is not None and rpe > 0:
            d["rpes"].append(rpe)

        # Track weekly best e1RM for change computation
        e1rm = row["best_e1rm"]
        if e1rm is not None and e1rm > 0:
            # Week number relative to mesocycle start
            try:
                start = datetime.strptime(d["start_date"], "%Y-%m-%d").date()
                delta_days = (training_date - start).days
                week_num = delta_days // 7
            except (TypeError, ValueError):
                week_num = 0
            current = d["weekly_e1rms"].get(week_num, 0.0)
            if float(e1rm) > current:
                d["weekly_e1rms"][week_num] = float(e1rm)

    # ── Find global max volume for normalization ─────────────────────────────

    all_total_volumes = [
        sum(d["volumes"]) for d in meso_data.values() if d["volumes"]
    ]
    global_max_volume = max(all_total_volumes) if all_total_volumes else 1.0

    # ── Build entries ─────────────────────────────────────────────────────────

    entries: list[MesocycleEntry] = []
    phase_e1rm_gains: dict[str, list[float]] = defaultdict(list)

    for mid, d in meso_data.items():
        # Weeks completed: count distinct ISO weeks with training
        iso_weeks = {dt.isocalendar()[:2] for dt in d["training_dates"]}
        weeks_completed = len(iso_weeks)

        # Cold start filter: need >= 2 weeks of data
        if weeks_completed < 2:
            continue

        total_volume = sum(d["volumes"]) if d["volumes"] else 0.0
        avg_rpe = round(sum(d["rpes"]) / len(d["rpes"]), 1) if d["rpes"] else None

        # Volume as fraction of max for alignment scoring
        volume_pct = total_volume / global_max_volume if global_max_volume > 0 else 0.0

        alignment = _alignment_score(d["phase"], avg_rpe, volume_pct)
        e1rm_change = _e1rm_change_pct(d["weekly_e1rms"])

        entries.append(
            MesocycleEntry(
                mesocycle_id=mid,
                name=d["name"],
                phase=d["phase"],
                start_date=d["start_date"],
                end_date=d["end_date"],
                weeks_completed=weeks_completed,
                alignment_score=alignment,
                avg_rpe=avg_rpe,
                total_volume_kg=round(total_volume, 1),
                e1rm_change_pct=e1rm_change,
            )
        )

        # Track e1RM gains per phase
        if e1rm_change is not None:
            phase_e1rm_gains[d["phase"]].append(e1rm_change)

    # ── Derive summary fields ─────────────────────────────────────────────────

    # Current phase: from the most recent mesocycle (entries are ordered by start_date DESC)
    current_phase = entries[0].phase if entries else None

    # Best phase for strength: highest average e1RM improvement
    best_phase: str | None = None
    best_avg_gain = float("-inf")
    for phase, gains in phase_e1rm_gains.items():
        avg_gain = sum(gains) / len(gains)
        if avg_gain > best_avg_gain:
            best_avg_gain = avg_gain
            best_phase = phase

    # Only report best phase if it actually produced positive gains
    if best_avg_gain <= 0:
        best_phase = None

    return MesocycleEffectivenessResponse(
        mesocycles=entries,
        total_mesocycles=len(entries),
        current_phase=current_phase,
        best_phase_for_strength=best_phase,
        period_days=period_days,
        disclaimer=(
            "Mesocycle effectiveness reflects observed patterns in your training data. "
            "Phase alignment is an estimate based on volume and intensity — "
            "individual programming may vary."
        ),
    )

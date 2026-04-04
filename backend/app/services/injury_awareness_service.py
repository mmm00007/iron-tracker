"""Injury awareness: active injury tracking, red flag detection, recovery trajectory."""

import asyncpg

from app.models.schemas import InjuryAwarenessResponse, InjuryEntry

# ─── Constants ────────────────────────────────────────────────────────────────

# Minimum injury reports before returning meaningful analysis.
MIN_REPORTS = 1

DISCLAIMER = (
    "Iron Tracker is NOT a medical device. Pain and injury data is for personal "
    "tracking only and does not constitute medical advice, diagnosis, or treatment. "
    "If you are experiencing pain, consult a qualified healthcare provider."
)

# ─── SQL ──────────────────────────────────────────────────────────────────────

_INJURY_QUERY = """\
SELECT ir.id::text AS injury_id, ir.body_area, ir.location_type,
       ir.pain_level, ir.status, ir.reported_at::text,
       ir.resolved_at::text, ir.onset_type,
       CASE WHEN ir.resolved_at IS NOT NULL
            THEN EXTRACT(DAY FROM ir.resolved_at - ir.reported_at)::int
            ELSE EXTRACT(DAY FROM NOW() - ir.reported_at)::int
       END AS days_active,
       (SELECT COUNT(*) FROM sets s
        WHERE s.user_id = ir.user_id
          AND s.exercise_id = ir.affected_exercise_id
          AND s.logged_at >= ir.reported_at
          AND ir.status != 'resolved') AS sets_while_injured
FROM injury_reports ir
WHERE ir.user_id = $1
ORDER BY ir.reported_at DESC
"""


# ─── Red flag detection ──────────────────────────────────────────────────────


def _detect_red_flags(active_injuries: list[InjuryEntry]) -> list[str]:
    """Detect red flags requiring medical attention.

    Three categories per sports medicine expert review:
    1. High pain (>= 7/10 NRS) persisting > 14 days — chronic unresolved pain
    2. Nerve-type location — nerve symptoms always warrant medical evaluation
    3. Training through significant pain (>= 5/10) — risk of aggravation
    """
    red_flags: list[str] = []

    for inj in active_injuries:
        if inj.pain_level >= 7 and inj.days_active is not None and inj.days_active > 14:
            red_flags.append(
                f"High pain ({inj.pain_level}/10) in {inj.body_area} "
                f"for {inj.days_active} days - consider medical evaluation"
            )
        if inj.location_type == "nerve":
            red_flags.append(
                f"Nerve-type issue reported in {inj.body_area} "
                f"- nerve symptoms warrant medical evaluation"
            )
        if inj.sets_while_injured > 0 and inj.pain_level >= 5:
            red_flags.append(
                f"Training through significant pain ({inj.pain_level}/10) in {inj.body_area}"
            )

    return red_flags


# ─── Main service function ────────────────────────────────────────────────────


async def compute_injury_awareness(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> InjuryAwarenessResponse:
    """Compute injury awareness: active injuries, red flags, and recovery stats.

    Algorithm:
    1. Query all injury_reports for the user.
    2. Active injuries = status != 'resolved'.
    3. Training-through-injury: check if sets exist for affected_exercise_id
       after reported_at where status != 'resolved'.
    4. Recovery trajectory: for resolved injuries, compute days_active.
    5. Red flags: high pain > 14 days, nerve-type, training through pain.

    Cold start: requires >= 1 injury report. Returns empty with disclaimer if none.
    """
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(_INJURY_QUERY, user_id)

    # ── Insufficient data ─────────────────────────────────────────────────
    if len(rows) < MIN_REPORTS:
        return InjuryAwarenessResponse(
            injuries=[],
            active_count=0,
            resolved_count=0,
            avg_recovery_days=None,
            red_flags=[],
            training_through_injury=False,
            disclaimer=DISCLAIMER,
        )

    # ── Build injury entries ──────────────────────────────────────────────
    injuries: list[InjuryEntry] = []
    for row in rows:
        injuries.append(
            InjuryEntry(
                injury_id=row["injury_id"],
                body_area=row["body_area"],
                location_type=row["location_type"],
                pain_level=int(row["pain_level"]),
                status=row["status"],
                reported_at=row["reported_at"],
                resolved_at=row["resolved_at"],
                days_active=int(row["days_active"]) if row["days_active"] is not None else None,
                sets_while_injured=int(row["sets_while_injured"]),
                onset_type=row["onset_type"],
            )
        )

    # ── Partition by status ───────────────────────────────────────────────
    active_injuries = [inj for inj in injuries if inj.status != "resolved"]
    resolved_injuries = [inj for inj in injuries if inj.status == "resolved"]

    active_count = len(active_injuries)
    resolved_count = len(resolved_injuries)

    # ── Recovery trajectory ───────────────────────────────────────────────
    recovery_days = [inj.days_active for inj in resolved_injuries if inj.days_active is not None]
    avg_recovery_days = round(sum(recovery_days) / len(recovery_days), 1) if recovery_days else None

    # ── Training-through-injury flag ──────────────────────────────────────
    training_through_injury = any(inj.sets_while_injured > 0 for inj in active_injuries)

    # ── Red flag detection ────────────────────────────────────────────────
    red_flags = _detect_red_flags(active_injuries)

    return InjuryAwarenessResponse(
        injuries=injuries,
        active_count=active_count,
        resolved_count=resolved_count,
        avg_recovery_days=avg_recovery_days,
        red_flags=red_flags,
        training_through_injury=training_through_injury,
        disclaimer=DISCLAIMER,
    )

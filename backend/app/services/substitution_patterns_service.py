"""Exercise substitution pattern analysis.

Finds exercise pairs from the substitution catalog where the user has logged
sets on BOTH the source and target exercise, then compares performance across
the pair.

Per pair:
1. Best estimated 1RM on source and target within the analysis period
2. Performance ratio (target e1RM / source e1RM)
3. For progression-type substitutions: readiness percentage based on
   current strength-to-bodyweight ratio vs. the prerequisite threshold

Cold start: requires at least one substitution pair where the user has
logged sets on both exercises within the period.
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    SubstitutionPairEntry,
    SubstitutionPatternsResponse,
)

_DISCLAIMER = (
    "Exercise substitution analysis is based on logged data. "
    "Performance differences between exercises may reflect training "
    "focus, not equipment superiority."
)

_PAIRS_SQL = """
SELECT es.source_exercise_id::text, es.target_exercise_id::text,
       es.substitution_type, es.similarity_score,
       es.prerequisite_1rm_ratio::float,
       src.name AS source_name, tgt.name AS target_name,
       (SELECT MAX(estimated_1rm) FROM sets WHERE user_id = $1
        AND exercise_id = es.source_exercise_id AND estimated_1rm > 0
        AND logged_at >= $2) AS source_e1rm,
       (SELECT MAX(estimated_1rm) FROM sets WHERE user_id = $1
        AND exercise_id = es.target_exercise_id AND estimated_1rm > 0
        AND logged_at >= $2) AS target_e1rm
FROM exercise_substitutions es
JOIN exercises src ON src.id = es.source_exercise_id
JOIN exercises tgt ON tgt.id = es.target_exercise_id
WHERE EXISTS (SELECT 1 FROM sets WHERE user_id = $1
              AND exercise_id = es.source_exercise_id AND logged_at >= $2)
  AND EXISTS (SELECT 1 FROM sets WHERE user_id = $1
              AND exercise_id = es.target_exercise_id AND logged_at >= $2)
ORDER BY es.similarity_score DESC NULLS LAST
"""

_BODYWEIGHT_SQL = """
SELECT weight, weight_unit
FROM body_weight_log
WHERE user_id = $1
ORDER BY logged_at DESC
LIMIT 1
"""


async def compute_substitution_patterns(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 180,
) -> SubstitutionPatternsResponse:
    """Analyze substitution pairs the user has actually trained.

    Returns performance ratios for each pair and, for progression-type
    substitutions, a readiness percentage derived from the user's
    current strength-to-bodyweight ratio relative to the prerequisite.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(_PAIRS_SQL, user_id, since)
        bw_row = await conn.fetchrow(_BODYWEIGHT_SQL, user_id)

    if not rows:
        return SubstitutionPatternsResponse(
            pairs=[],
            total_pairs_used=0,
            progressions_ready=0,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # ── Resolve bodyweight in kg ───────────────────────────────────────────
    bw_kg: float | None = None
    if bw_row and bw_row["weight"] and float(bw_row["weight"]) > 0:
        weight = float(bw_row["weight"])
        unit = (bw_row["weight_unit"] or "kg").lower().strip()
        bw_kg = weight * 0.453592 if unit == "lb" else weight

    # ── Build pair entries ─────────────────────────────────────────────────
    pairs: list[SubstitutionPairEntry] = []
    progressions_ready = 0

    for row in rows:
        source_e1rm = float(row["source_e1rm"]) if row["source_e1rm"] else None
        target_e1rm = float(row["target_e1rm"]) if row["target_e1rm"] else None

        # Performance ratio: target / source
        performance_ratio: float | None = None
        if source_e1rm and target_e1rm and source_e1rm > 0:
            performance_ratio = round(target_e1rm / source_e1rm, 3)

        # Readiness for progression-type substitutions
        readiness_pct: float | None = None
        sub_type = row["substitution_type"]
        prereq_ratio = row["prerequisite_1rm_ratio"]

        if sub_type == "progression" and prereq_ratio and source_e1rm:
            if bw_kg and bw_kg > 0 and float(prereq_ratio) > 0:
                readiness_pct = round(
                    min(
                        100.0,
                        (source_e1rm / bw_kg) / float(prereq_ratio) * 100,
                    ),
                    1,
                )
                if readiness_pct >= 100.0:
                    progressions_ready += 1

        pairs.append(
            SubstitutionPairEntry(
                source_name=row["source_name"],
                target_name=row["target_name"],
                substitution_type=sub_type,
                similarity_score=row["similarity_score"],
                source_e1rm=round(source_e1rm, 1) if source_e1rm else None,
                target_e1rm=round(target_e1rm, 1) if target_e1rm else None,
                performance_ratio=performance_ratio,
                readiness_pct=readiness_pct,
            )
        )

    return SubstitutionPatternsResponse(
        pairs=pairs,
        total_pairs_used=len(pairs),
        progressions_ready=progressions_ready,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

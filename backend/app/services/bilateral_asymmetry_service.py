"""Bilateral strength asymmetry detection using the Limb Symmetry Index (LSI).

The LSI is the standard metric in sports medicine and rehabilitation for
quantifying strength differences between limbs (Knapik et al. 1991,
Impellizzeri et al. 2007). It expresses the weaker side as a percentage
of the stronger side.

Formula:
  LSI = (weaker_e1rm / stronger_e1rm) * 100
  asymmetry_pct = 100 - LSI

Severity thresholds (validated by sports medicine expert):
  <8%   — normal (within expected biological variation)
  8-15% — monitor (may benefit from unilateral accessory work)
  >15%  — significant (targeted correction recommended)

Minimum 3 sets per side required before computing to avoid noise
from single-session variation.
"""

from datetime import UTC, datetime, timedelta
from itertools import groupby

import asyncpg

from app.models.schemas import AsymmetryExerciseEntry, BilateralAsymmetryResponse

_DISCLAIMER = (
    "Strength differences between sides are normal to some degree. "
    "These estimates are based on self-logged training data, not clinical testing. "
    "A consistent asymmetry above 15% may benefit from targeted unilateral training. "
    "If you experience pain on one side, consult a physiotherapist or sports medicine provider."
)

_MIN_SETS_PER_SIDE = 3


def _classify_severity(asymmetry_pct: float) -> str:
    """Classify asymmetry percentage into severity tier."""
    # LSI thresholds per Knapik et al. (1991), Bishop et al. (2018)
    if asymmetry_pct < 8:
        return "normal"
    if asymmetry_pct <= 15:
        return "monitor"
    return "significant"


async def compute_bilateral_asymmetry(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> BilateralAsymmetryResponse:
    """Compute bilateral strength asymmetry for all side-tagged exercises.

    Groups sets by exercise and side, computes the LSI for each exercise,
    and flags exercises exceeding the 8% asymmetry threshold.
    """
    cutoff = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                s.exercise_id,
                e.name AS exercise_name,
                e.laterality,
                s.side,
                COUNT(*) AS set_count,
                MAX(s.estimated_1rm) AS best_e1rm,
                SUM(
                    CASE WHEN s.weight_unit = 'lb'
                         THEN s.weight * 0.453592
                         ELSE s.weight
                    END * s.reps
                ) AS total_volume
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.side IS NOT NULL
              AND s.estimated_1rm > 0
              AND s.reps > 0
            GROUP BY s.exercise_id, e.name, e.laterality, s.side
            ORDER BY s.exercise_id, s.side
            """,
            user_id,
            cutoff,
        )

    # Cold-start: no side-tagged sets at all
    if not rows:
        return BilateralAsymmetryResponse(
            exercises=[],
            avg_asymmetry=None,
            flagged_count=0,
            normal_count=0,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # Group rows by exercise_id to pair left/right sides
    exercises: list[AsymmetryExerciseEntry] = []

    for exercise_id, group in groupby(rows, key=lambda r: r["exercise_id"]):
        sides: dict[str, dict] = {}
        for row in group:
            sides[row["side"].lower()] = {
                "e1rm": float(row["best_e1rm"]),
                "volume": float(row["total_volume"]),
                "set_count": int(row["set_count"]),
                "exercise_name": row["exercise_name"],
                "laterality": row["laterality"],
            }

        # Need both left and right with minimum data points
        if "left" not in sides or "right" not in sides:
            continue
        if sides["left"]["set_count"] < _MIN_SETS_PER_SIDE:
            continue
        if sides["right"]["set_count"] < _MIN_SETS_PER_SIDE:
            continue

        left_e1rm = sides["left"]["e1rm"]
        right_e1rm = sides["right"]["e1rm"]

        stronger = max(left_e1rm, right_e1rm)
        weaker = min(left_e1rm, right_e1rm)

        # Avoid division by zero (shouldn't happen given estimated_1rm > 0 filter)
        if stronger == 0:
            continue

        lsi = round((weaker / stronger) * 100, 1)
        asymmetry_pct = round(100 - lsi, 1)
        dominant_side = "left" if left_e1rm > right_e1rm else "right"

        exercises.append(
            AsymmetryExerciseEntry(
                exercise_id=exercise_id,
                exercise_name=sides["left"]["exercise_name"],
                laterality=sides["left"]["laterality"],
                left_e1rm=round(left_e1rm, 1),
                right_e1rm=round(right_e1rm, 1),
                asymmetry_pct=asymmetry_pct,
                lsi=lsi,
                dominant_side=dominant_side,
                severity=_classify_severity(asymmetry_pct),
                left_volume=round(sides["left"]["volume"], 1),
                right_volume=round(sides["right"]["volume"], 1),
                data_points_left=sides["left"]["set_count"],
                data_points_right=sides["right"]["set_count"],
            )
        )

    flagged = [e for e in exercises if e.asymmetry_pct >= 8]
    normal = [e for e in exercises if e.asymmetry_pct < 8]
    avg_asymmetry = (
        round(sum(e.asymmetry_pct for e in exercises) / len(exercises), 1) if exercises else None
    )

    return BilateralAsymmetryResponse(
        exercises=exercises,
        avg_asymmetry=avg_asymmetry,
        flagged_count=len(flagged),
        normal_count=len(normal),
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

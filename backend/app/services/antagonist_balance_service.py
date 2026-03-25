"""Antagonist muscle-pair balance analysis using activation-weighted volume ratios.

Compares training volume between opposing muscle groups (agonist/antagonist pairs)
to detect imbalances that may increase injury risk or limit performance.

Per-pair thresholds based on published research:
  - Chest:Lats ratio >1.5 flags anterior dominance (Kolber et al. 2009)
  - Hamstring:Quad ratio <0.6 flags ACL/hamstring injury risk (Hewett et al. 2005)
  - Other pairs use a generic >1.5 threshold

Volume is activation-weighted: primary muscles receive full credit (1.0),
secondary muscles receive half credit (0.5).

Status tiers:
  "balanced"                — ratio within acceptable range
  "moderate_imbalance"      — ratio exceeds first threshold
  "significant_imbalance"   — ratio exceeds second threshold
  "insufficient_data"       — no volume data for one or both muscles in the pair
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import AntagonistBalanceResponse, AntagonistPairEntry

_DISCLAIMER = (
    "Imbalance detection is based on training volume ratios and general population "
    "research. Individual anatomy and training goals affect optimal ratios."
)


def _classify_pair(pair_name: str, ratio: float | None) -> str:
    """Classify a muscle pair's balance status based on its volume ratio."""
    if ratio is None:
        return "insufficient_data"

    # For hamstring:quad, the concern is when hamstrings are too LOW relative to quads
    if "hamstring" in pair_name.lower() and "quad" in pair_name.lower():
        if ratio < 0.6:
            return "significant_imbalance"
        if ratio < 0.8:
            return "moderate_imbalance"
        return "balanced"

    # For all other pairs, flag when the ratio diverges too far from 1.0
    if ratio > 2.0:
        return "significant_imbalance"
    if ratio > 1.5:
        return "moderate_imbalance"
    return "balanced"


def _recommendation_for_pair(
    pair_name: str,
    muscle_a: str,
    muscle_b: str,
    volume_a: float,
    volume_b: float,
    status: str,
) -> str:
    """Generate a per-pair recommendation based on imbalance status."""
    if status == "balanced":
        return "Volume is well-balanced for this pair. Keep it up."
    if status == "insufficient_data":
        return "Not enough training data for this pair yet."

    weaker = muscle_b if volume_a > volume_b else muscle_a
    return f"Consider adding more {weaker} volume to balance this pair."


async def compute_antagonist_balance(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> AntagonistBalanceResponse:
    """Compute antagonist muscle-pair balance from activation-weighted volume.

    Queries all defined antagonist pairs and the user's per-muscle training
    volume over the given period. For each pair, computes the volume ratio
    (higher / lower) and classifies balance status.
    """
    cutoff = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        # 1. Fetch all antagonist pairs with muscle names
        pairs = await conn.fetch(
            """
            SELECT
                map.id AS pair_id,
                map.pair_name,
                map.pair_strength,
                map.muscle_a_id,
                mga.name AS muscle_a_name,
                map.muscle_b_id,
                mgb.name AS muscle_b_name
            FROM muscle_antagonist_pairs map
            JOIN muscle_groups mga ON mga.id = map.muscle_a_id
            JOIN muscle_groups mgb ON mgb.id = map.muscle_b_id
            """,
        )

        # 2. Fetch per-muscle activation-weighted volume
        volume_rows = await conn.fetch(
            """
            SELECT
                em.muscle_group_id,
                SUM(
                    CASE WHEN s.weight_unit = 'lb'
                         THEN s.weight * 0.453592
                         ELSE s.weight
                    END
                    * s.reps
                    * CASE WHEN em.is_primary THEN 1.0 ELSE 0.5 END
                ) AS weighted_volume
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.set_type IN ('working', 'backoff', 'failure')
              AND s.reps > 0
            GROUP BY em.muscle_group_id
            """,
            user_id,
            cutoff,
        )

    # Cold-start: no antagonist pairs defined
    if not pairs:
        return AntagonistBalanceResponse(
            pairs=[],
            imbalanced_count=0,
            balanced_count=0,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # Build a lookup: muscle_group_id -> weighted_volume
    volume_map: dict[str, float] = {
        str(row["muscle_group_id"]): float(row["weighted_volume"])
        for row in volume_rows
    }

    # 3. Match volumes to pairs and compute ratios
    entries: list[AntagonistPairEntry] = []

    for pair in pairs:
        muscle_a_id = str(pair["muscle_a_id"])
        muscle_b_id = str(pair["muscle_b_id"])
        muscle_a_name = pair["muscle_a_name"]
        muscle_b_name = pair["muscle_b_name"]
        pair_name = pair["pair_name"]

        vol_a = volume_map.get(muscle_a_id)
        vol_b = volume_map.get(muscle_b_id)

        # Skip pairs where either muscle has no data (cold start for this pair)
        if vol_a is None or vol_b is None:
            continue

        # Compute ratio: higher over lower for generic pairs
        # For hamstring:quad, ratio = hamstring / quad (order matters)
        if "hamstring" in pair_name.lower() and "quad" in pair_name.lower():
            # Determine which side is hamstring vs quad based on muscle names
            if "hamstring" in muscle_a_name.lower():
                ratio = round(vol_a / vol_b, 2) if vol_b > 0 else None
            else:
                ratio = round(vol_b / vol_a, 2) if vol_a > 0 else None
        else:
            # Generic: higher / lower
            higher = max(vol_a, vol_b)
            lower = min(vol_a, vol_b)
            ratio = round(higher / lower, 2) if lower > 0 else None

        status = _classify_pair(pair_name, ratio)
        recommendation = _recommendation_for_pair(
            pair_name, muscle_a_name, muscle_b_name, vol_a, vol_b, status
        )

        entries.append(
            AntagonistPairEntry(
                pair_name=pair_name,
                muscle_a=muscle_a_name,
                muscle_b=muscle_b_name,
                volume_a=round(vol_a, 1),
                volume_b=round(vol_b, 1),
                ratio=ratio,
                status=status,
                recommendation=recommendation,
            )
        )

    imbalanced = [
        e for e in entries if e.status in ("moderate_imbalance", "significant_imbalance")
    ]
    balanced = [e for e in entries if e.status == "balanced"]

    return AntagonistBalanceResponse(
        pairs=entries,
        imbalanced_count=len(imbalanced),
        balanced_count=len(balanced),
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

"""Volume landmarks per muscle group based on Renaissance Periodization research.

Reference: Israetel, M., Hoffmann, J., & Smith, C. (2021).
Scientific Principles of Hypertrophy Training. RP Publications.

Volume landmarks represent weekly set thresholds:
- MV  (Maintenance Volume):  Minimum to prevent muscle loss
- MEV (Minimum Effective Volume): Minimum to drive adaptation
- MAV (Maximum Adaptive Volume): Optimal volume for most lifters
- MRV (Maximum Recoverable Volume): Upper limit before recovery fails
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    MuscleLandmarkEntry,
    VolumeLandmarksResponse,
)

# ─── Per-muscle-group volume landmarks (sets/week) ───────────────────────────
# Values for intermediate lifters. Based on RP Hypertrophy Training Guide
# and Schoenfeld meta-analyses on dose-response for hypertrophy.
# Volume landmarks per Israetel et al., RP Hypertrophy Guide (2023)

# Keys MUST match muscle_groups.name from DB exactly (lowercase, from wger seed).
VOLUME_LANDMARKS: dict[str, dict[str, float]] = {
    "chest": {"MV": 6, "MEV": 8, "MAV": 16, "MRV": 22},
    "lats": {"MV": 6, "MEV": 10, "MAV": 18, "MRV": 25},
    "traps": {"MV": 0, "MEV": 4, "MAV": 12, "MRV": 20},
    "shoulders": {"MV": 6, "MEV": 8, "MAV": 16, "MRV": 22},
    "biceps": {"MV": 4, "MEV": 6, "MAV": 14, "MRV": 20},
    "triceps": {"MV": 4, "MEV": 6, "MAV": 14, "MRV": 18},
    "quadriceps": {"MV": 6, "MEV": 10, "MAV": 16, "MRV": 20},
    "hamstrings": {"MV": 4, "MEV": 6, "MAV": 14, "MRV": 18},
    "glutes": {"MV": 0, "MEV": 4, "MAV": 12, "MRV": 20},
    "calves": {"MV": 6, "MEV": 8, "MAV": 14, "MRV": 20},
    "abs": {"MV": 0, "MEV": 4, "MAV": 16, "MRV": 20},
    "forearms": {"MV": 0, "MEV": 2, "MAV": 10, "MRV": 16},
    "lower back": {"MV": 0, "MEV": 2, "MAV": 10, "MRV": 14},
    "adductors": {"MV": 0, "MEV": 2, "MAV": 12, "MRV": 16},
}

DEFAULT_LANDMARKS: dict[str, float] = {"MV": 4, "MEV": 6, "MAV": 14, "MRV": 20}


def _classify_volume(sets: float, landmarks: dict[str, float]) -> tuple[str, str]:
    """Classify current volume and return (status, recommendation)."""
    if sets < landmarks["MV"]:
        return (
            "below_mv",
            "Below maintenance volume — muscle may atrophy. Consider adding sets.",
        )
    if sets < landmarks["MEV"]:
        return (
            "maintenance",
            "At maintenance volume — sufficient to prevent loss, but insufficient for growth.",
        )
    if sets <= landmarks["MAV"]:
        return (
            "productive",
            "In the productive range — good stimulus for hypertrophy.",
        )
    if sets <= landmarks["MRV"]:
        return (
            "approaching_mrv",
            "Approaching maximum recoverable volume — monitor recovery closely.",
        )
    return (
        "over_mrv",
        "Exceeding MRV — high risk of overreaching. Consider reducing volume or deloading.",
    )


async def compute_volume_landmarks(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> VolumeLandmarksResponse:
    """Compute weekly set count per muscle group and compare against landmarks.

    Sets are weighted: primary muscles count as 1.0 set, secondary as 0.5.
    Only the most recent 7 days are analyzed.
    """
    since = datetime.now(UTC) - timedelta(days=7)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                mg.name           AS muscle_group,
                em.is_primary,
                COUNT(*)          AS set_count
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.weight > 0
              AND s.reps > 0
            GROUP BY mg.name, em.is_primary
            """,
            user_id,
            since,
        )

    # Aggregate weighted sets per muscle
    muscle_sets: dict[str, float] = {}
    for row in rows:
        name = row["muscle_group"]
        weight = 1.0 if row["is_primary"] else 0.5
        muscle_sets[name] = muscle_sets.get(name, 0.0) + int(row["set_count"]) * weight

    entries: list[MuscleLandmarkEntry] = []
    muscles_over_mrv = 0
    muscles_below_mev = 0

    for name, current_sets in sorted(muscle_sets.items()):
        landmarks = VOLUME_LANDMARKS.get(name, DEFAULT_LANDMARKS)
        status, recommendation = _classify_volume(current_sets, landmarks)

        if status == "over_mrv":
            muscles_over_mrv += 1
        if status == "below_mv" or (status == "maintenance" and current_sets < landmarks["MEV"]):
            muscles_below_mev += 1

        entries.append(
            MuscleLandmarkEntry(
                muscle_group=name,
                current_sets=round(current_sets, 1),
                mv=landmarks["MV"],
                mev=landmarks["MEV"],
                mav=landmarks["MAV"],
                mrv=landmarks["MRV"],
                status=status,
                recommendation=recommendation,
            )
        )

    return VolumeLandmarksResponse(
        muscles=entries,
        total_weekly_sets=round(sum(e.current_sets for e in entries), 1),
        muscles_over_mrv=muscles_over_mrv,
        muscles_below_mev=muscles_below_mev,
    )

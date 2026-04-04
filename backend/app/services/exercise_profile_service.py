"""Exercise profile completeness analysis.

Aggregates user annotations across exercises to measure how thoroughly
the user has profiled their exercise library. Tracks:
1. Per-exercise completeness: % of profile fields populated
   (form cues, preferred grip/stance/rep range, tags, set history)
2. Aggregate stats: avg completeness, injury flag count, tag distribution

Completeness denominator is 5 fields:
  form_cues, preferred_grip, preferred_stance, preferred_rep_range, tags.

Cold start: requires at least one exercise with notes, tags, or logged sets.
"""

import asyncpg

from app.models.schemas import ExerciseProfileEntry, ExerciseProfileResponse

_DISCLAIMER = (
    "Exercise profile data reflects your personal annotations. "
    "Injury notes are for your own reference and do not constitute "
    "medical assessment."
)

_COMPLETENESS_FIELDS = 5  # form_cues, preferred_grip, preferred_stance, preferred_rep_range, tags


def _completeness(row: asyncpg.Record) -> float:
    """Compute profile completeness percentage for a single exercise.

    Fields counted (5 total):
      form_cues, preferred_grip, preferred_stance, preferred_rep_range, tags
    """
    filled = 0
    if row["form_cues"]:
        filled += 1
    if row["preferred_grip"]:
        filled += 1
    if row["preferred_stance"]:
        filled += 1
    if row["preferred_rep_range"]:
        filled += 1
    if row["tags"]:
        filled += 1
    return round(filled / _COMPLETENESS_FIELDS * 100, 1)


async def compute_exercise_profile(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> ExerciseProfileResponse:
    """Build the exercise profile for a user.

    Returns per-exercise completeness entries plus aggregate stats
    (avg completeness, injury flags, tag distribution).
    """
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT e.id::text AS exercise_id, e.name AS exercise_name,
                   uen.form_cues, uen.injury_notes,
                   uen.preferred_grip, uen.preferred_stance,
                   uen.preferred_rep_range,
                   COALESCE(
                     (SELECT array_agg(et.tag) FROM exercise_tags et
                      WHERE et.user_id = $1 AND et.exercise_id = e.id),
                     ARRAY[]::text[]
                   ) AS tags,
                   COALESCE(
                     (SELECT COUNT(*) FROM sets s
                      WHERE s.user_id = $1 AND s.exercise_id = e.id),
                     0
                   ) AS total_sets
            FROM exercises e
            LEFT JOIN user_exercise_notes uen
              ON uen.exercise_id = e.id AND uen.user_id = $1
            WHERE EXISTS (
                    SELECT 1 FROM sets WHERE user_id = $1 AND exercise_id = e.id
                  )
               OR uen.id IS NOT NULL
               OR EXISTS (
                    SELECT 1 FROM exercise_tags
                    WHERE user_id = $1 AND exercise_id = e.id
                  )
            ORDER BY total_sets DESC
            """,
            user_id,
        )

    if not rows:
        return ExerciseProfileResponse(
            exercises=[],
            avg_completeness=0.0,
            exercises_with_notes=0,
            exercises_with_injury_flags=0,
            total_tags=0,
            unique_tags=0,
            disclaimer=_DISCLAIMER,
        )

    # Build per-exercise entries
    exercises: list[ExerciseProfileEntry] = []
    all_tags: list[str] = []
    injury_count = 0
    notes_count = 0

    for row in rows:
        pct = _completeness(row)
        tags: list[str] = list(row["tags"]) if row["tags"] else []
        all_tags.extend(tags)

        has_form = bool(row["form_cues"])
        has_injury = bool(row["injury_notes"])
        if has_injury:
            injury_count += 1
        has_prefs = row["preferred_grip"] or row["preferred_stance"] or row["preferred_rep_range"]
        if has_form or has_prefs:
            notes_count += 1

        exercises.append(
            ExerciseProfileEntry(
                exercise_id=row["exercise_id"],
                exercise_name=row["exercise_name"],
                has_form_cues=has_form,
                has_injury_notes=has_injury,
                preferred_grip=row["preferred_grip"],
                preferred_stance=row["preferred_stance"],
                preferred_rep_range=row["preferred_rep_range"],
                tags=tags,
                total_sets=int(row["total_sets"]),
                completeness_pct=pct,
            )
        )

    avg_completeness = round(sum(e.completeness_pct for e in exercises) / len(exercises), 1)

    return ExerciseProfileResponse(
        exercises=exercises,
        avg_completeness=avg_completeness,
        exercises_with_notes=notes_count,
        exercises_with_injury_flags=injury_count,
        total_tags=len(all_tags),
        unique_tags=len(set(all_tags)),
        disclaimer=_DISCLAIMER,
    )

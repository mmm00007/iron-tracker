from app.models.schemas import ExerciseE1RM, WeeklySummary


async def compute_weekly_summary(user_id: str, supabase_client: object) -> WeeklySummary:
    """Compute weekly training summary for a user.

    Stub implementation — returns placeholder data until Supabase queries are wired up.
    """
    # TODO: Query Supabase for actual workout data
    # Example query pattern:
    # result = supabase_client.table("sets")
    #     .select("reps, weight, created_at")
    #     .eq("user_id", user_id)
    #     .gte("created_at", week_start.isoformat())
    #     .execute()
    return WeeklySummary(
        total_sets=0,
        total_volume=0.0,
        training_days=0,
        delta_sets=None,
        delta_volume=None,
    )


async def compute_1rm_trend(
    user_id: str,
    exercise_id: str,
    supabase_client: object,
) -> list[ExerciseE1RM]:
    """Compute estimated 1RM trend for a given exercise.

    Stub implementation — returns placeholder data until Supabase queries are wired up.
    Uses the Epley formula: 1RM = weight * (1 + reps / 30)
    """
    # TODO: Query Supabase for actual set data grouped by date
    # Example query pattern:
    # result = supabase_client.table("sets")
    #     .select("weight, reps, created_at")
    #     .eq("user_id", user_id)
    #     .eq("exercise_id", exercise_id)
    #     .order("created_at")
    #     .execute()
    return []

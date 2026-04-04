from unittest.mock import MagicMock

from app.services.weekly_summary_service import generate_weekly_summaries

# ── Tests ────────────────────────────────────────────────────────────────────


async def test_generate_summaries(mock_db_pool: MagicMock) -> None:
    """Should generate summaries for users who trained in the last 7 days."""
    conn = mock_db_pool._conn

    # First call: find active users
    # Second call (inside _generate_user_summary): fetch training data
    user_rows = [{"user_id": "user-1"}, {"user_id": "user-2"}]

    training_rows = [
        {
            "weight": 100.0,
            "reps": 5,
            "rpe": 8.0,
            "set_type": "working",
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-20")),
            "exercise_name": "Bench Press",
            "category": "chest",
        },
        {
            "weight": 80.0,
            "reps": 10,
            "rpe": 7.5,
            "set_type": "working",
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-21")),
            "exercise_name": "Squat",
            "category": "legs",
        },
    ]

    # First call returns user_ids, subsequent calls return training data.
    # Advanced metrics (muscle_workload, volume_landmarks, body_part_balance)
    # each call pool.acquire() -> conn.fetch(), so we provide empty results
    # for those secondary queries per user.
    conn.fetch.side_effect = [
        user_rows,  # user list
        training_rows,  # user-1 training data
        [],  # user-1 muscle workload
        [],  # user-1 volume landmarks
        [],  # user-1 body part balance
        training_rows,  # user-2 training data
        [],  # user-2 muscle workload
        [],  # user-2 volume landmarks
        [],  # user-2 body part balance
    ]
    conn.execute.return_value = None

    count = await generate_weekly_summaries(mock_db_pool)

    assert count == 2
    # Verify INSERT was called for each user summary
    assert conn.execute.call_count == 2


async def test_skip_inactive_user(mock_db_pool: MagicMock) -> None:
    """Users with no recent sets should be skipped (no summary generated)."""
    conn = mock_db_pool._conn

    # First call: find active users (still returns the user because they had *some* activity)
    user_rows = [{"user_id": "user-inactive"}]

    # Second call: no training rows for this user in the detailed query
    conn.fetch.side_effect = [user_rows, []]
    conn.execute.return_value = None

    count = await generate_weekly_summaries(mock_db_pool)

    # _generate_user_summary returns early when rows is empty,
    # but the function still counts it as processed (count += 1)
    # because the exception path is not triggered.
    assert count == 1
    # No INSERT should have been called since there were no rows
    conn.execute.assert_not_called()


async def test_generate_summaries_no_active_users(mock_db_pool: MagicMock) -> None:
    """When no users have trained recently, zero summaries should be generated."""
    conn = mock_db_pool._conn
    conn.fetch.return_value = []

    count = await generate_weekly_summaries(mock_db_pool)

    assert count == 0


async def test_generate_summaries_handles_error(mock_db_pool: MagicMock) -> None:
    """If one user's summary fails, it should continue to the next user."""
    conn = mock_db_pool._conn

    user_rows = [{"user_id": "user-fail"}, {"user_id": "user-ok"}]

    training_rows_ok = [
        {
            "weight": 60.0,
            "reps": 12,
            "rpe": 7.0,
            "set_type": "working",
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-22")),
            "exercise_name": "Lat Pulldown",
            "category": "back",
        },
    ]

    # First call: user list. Second call (user-fail): raise exception.
    # Third call (user-ok): return training data + empty advanced metrics.
    conn.fetch.side_effect = [
        user_rows,
        Exception("DB error"),  # user-fail training data
        training_rows_ok,  # user-ok training data
        [],  # user-ok muscle workload
        [],  # user-ok volume landmarks
        [],  # user-ok body part balance
    ]
    conn.execute.return_value = None

    count = await generate_weekly_summaries(mock_db_pool)

    # Only user-ok should succeed
    assert count == 1

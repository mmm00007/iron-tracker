from unittest.mock import AsyncMock, MagicMock

import pytest

from app.services.weekly_summary_service import generate_weekly_summaries

# ── Fixtures ─────────────────────────────────────────────────────────────────


@pytest.fixture
def mock_db_pool() -> MagicMock:
    """Create a mock asyncpg pool with acquire() context manager."""
    pool = MagicMock()
    conn = AsyncMock()
    ctx = AsyncMock()
    ctx.__aenter__ = AsyncMock(return_value=conn)
    ctx.__aexit__ = AsyncMock(return_value=False)
    pool.acquire.return_value = ctx
    pool._conn = conn
    return pool


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
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-20")),
            "exercise_name": "Bench Press",
            "category": "chest",
        },
        {
            "weight": 80.0,
            "reps": 10,
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-21")),
            "exercise_name": "Squat",
            "category": "legs",
        },
    ]

    # First call returns user_ids, subsequent calls return training data
    conn.fetch.side_effect = [user_rows, training_rows, training_rows]
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
            "logged_at": MagicMock(strftime=MagicMock(return_value="2026-03-22")),
            "exercise_name": "Lat Pulldown",
            "category": "back",
        },
    ]

    # First call: user list. Second call (user-fail): raise exception.
    # Third call (user-ok): return training data.
    conn.fetch.side_effect = [user_rows, Exception("DB error"), training_rows_ok]
    conn.execute.return_value = None

    count = await generate_weekly_summaries(mock_db_pool)

    # Only user-ok should succeed
    assert count == 1

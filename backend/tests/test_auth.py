from datetime import UTC, datetime, timedelta

import pytest
from fastapi import HTTPException
from jose import jwt

from app.auth import get_current_user
from app.config import Settings

# Shared test secret and algorithm
_TEST_SECRET = "test-jwt-secret-for-unit-tests"
_ALGORITHM = "HS256"


def _make_settings(**overrides) -> Settings:
    defaults = {
        "SUPABASE_URL": "https://test.supabase.co",
        "SUPABASE_DB_URL": "postgresql://localhost/test",
        "SUPABASE_JWT_SECRET": _TEST_SECRET,
        "ANTHROPIC_API_KEY": "",
    }
    defaults.update(overrides)
    return Settings(**defaults)


def _encode_jwt(payload: dict) -> str:
    return jwt.encode(payload, _TEST_SECRET, algorithm=_ALGORITHM)


class _FakeCredentials:
    """Mimics HTTPAuthorizationCredentials with a .credentials attribute."""

    def __init__(self, token: str) -> None:
        self.credentials = token


# ── Tests ────────────────────────────────────────────────────────────────────


async def test_valid_jwt_returns_user_id() -> None:
    """A properly signed JWT with 'sub' should return the user_id."""
    user_id = "user-abc-123"
    token = _encode_jwt(
        {
            "sub": user_id,
            "aud": "authenticated",
            "exp": datetime.now(UTC) + timedelta(hours=1),
        }
    )

    result = await get_current_user(
        credentials=_FakeCredentials(token),
        settings=_make_settings(),
    )
    assert result == user_id


async def test_expired_jwt_raises_401() -> None:
    """An expired JWT should raise HTTPException with status 401."""
    token = _encode_jwt(
        {
            "sub": "user-abc-123",
            "aud": "authenticated",
            "exp": datetime.now(UTC) - timedelta(hours=1),
        }
    )

    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(
            credentials=_FakeCredentials(token),
            settings=_make_settings(),
        )
    assert exc_info.value.status_code == 401


async def test_missing_sub_raises_401() -> None:
    """A JWT without a 'sub' claim should raise HTTPException 401."""
    token = _encode_jwt(
        {
            "aud": "authenticated",
            "exp": datetime.now(UTC) + timedelta(hours=1),
        }
    )

    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(
            credentials=_FakeCredentials(token),
            settings=_make_settings(),
        )
    assert exc_info.value.status_code == 401


async def test_malformed_token_raises_401() -> None:
    """A garbage token should raise HTTPException 401."""
    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(
            credentials=_FakeCredentials("garbage"),
            settings=_make_settings(),
        )
    assert exc_info.value.status_code == 401

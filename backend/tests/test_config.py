import os
from unittest.mock import patch

from app.config import Settings


def test_settings_from_env() -> None:
    """Settings should pick up values from environment variables."""
    env = {
        "SUPABASE_URL": "https://my-project.supabase.co",
        "SUPABASE_DB_URL": "postgresql://db.supabase.co:5432/postgres",
        "SUPABASE_JWT_SECRET": "super-secret",
        "ANTHROPIC_API_KEY": "sk-ant-test",
        "ALLOWED_ORIGINS": "http://localhost:3000",
        "AI_RATE_LIMIT_PER_DAY": "20",
        "DEBUG": "true",
    }
    with patch.dict(os.environ, env, clear=False):
        settings = Settings()

    assert settings.SUPABASE_URL == "https://my-project.supabase.co"
    assert settings.SUPABASE_DB_URL == "postgresql://db.supabase.co:5432/postgres"
    assert settings.SUPABASE_JWT_SECRET == "super-secret"
    assert settings.ANTHROPIC_API_KEY == "sk-ant-test"
    assert settings.AI_RATE_LIMIT_PER_DAY == 20
    assert settings.DEBUG is True


def test_settings_defaults() -> None:
    """Settings should use default values when env vars are not set."""
    env = {
        "SUPABASE_URL": "https://test.supabase.co",
        "SUPABASE_DB_URL": "postgresql://localhost/test",
        "SUPABASE_JWT_SECRET": "secret",
    }
    with patch.dict(os.environ, env, clear=False):
        settings = Settings()

    assert settings.ANTHROPIC_API_KEY == ""
    assert settings.ALLOWED_ORIGINS == "http://localhost:5173"
    assert settings.SENTRY_DSN == ""
    assert settings.AI_RATE_LIMIT_PER_DAY == 10
    assert settings.DEBUG is False


def test_allowed_origins_list_single() -> None:
    """allowed_origins_list should return a single-element list for one origin."""
    settings = Settings(
        SUPABASE_URL="https://test.supabase.co",
        SUPABASE_DB_URL="postgresql://localhost/test",
        SUPABASE_JWT_SECRET="secret",
        ALLOWED_ORIGINS="http://localhost:5173",
    )
    assert settings.allowed_origins_list == ["http://localhost:5173"]


def test_allowed_origins_list_multiple() -> None:
    """allowed_origins_list should split comma-separated origins and strip whitespace."""
    settings = Settings(
        SUPABASE_URL="https://test.supabase.co",
        SUPABASE_DB_URL="postgresql://localhost/test",
        SUPABASE_JWT_SECRET="secret",
        ALLOWED_ORIGINS="http://localhost:5173, https://app.example.com , https://staging.example.com",
    )
    assert settings.allowed_origins_list == [
        "http://localhost:5173",
        "https://app.example.com",
        "https://staging.example.com",
    ]

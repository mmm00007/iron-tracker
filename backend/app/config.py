from functools import lru_cache
from typing import Annotated

from pydantic import BeforeValidator
from pydantic_settings import BaseSettings, SettingsConfigDict


def _parse_origins(v: str | list[str]) -> list[str]:
    if isinstance(v, str):
        return [origin.strip() for origin in v.split(",")]
    return v


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    SUPABASE_URL: str
    SUPABASE_DB_URL: str
    SUPABASE_JWT_SECRET: str
    ANTHROPIC_API_KEY: str = ""
    ALLOWED_ORIGINS: Annotated[list[str], BeforeValidator(_parse_origins)] = ["http://localhost:5173"]
    SENTRY_DSN: str = ""
    AI_RATE_LIMIT_PER_DAY: int = 10
    DEBUG: bool = False


@lru_cache
def get_settings() -> Settings:
    return Settings()

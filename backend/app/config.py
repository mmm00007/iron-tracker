from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    SUPABASE_URL: str = ""
    SUPABASE_DB_URL: str
    SUPABASE_JWT_SECRET: str
    ANTHROPIC_API_KEY: str = ""
    ALLOWED_ORIGINS: str = "http://localhost:5173"
    SENTRY_DSN: str = ""
    AI_RATE_LIMIT_PER_DAY: int = 10
    DEBUG: bool = False
    CRON_SECRET: str = ""

    @field_validator("CRON_SECRET")
    @classmethod
    def validate_cron_secret(cls, v: str) -> str:
        """Require minimum 32 non-whitespace chars when set."""
        if v and (len(v.strip()) < 32):
            raise ValueError("CRON_SECRET must be at least 32 non-whitespace characters when set")
        return v

    # Feature flags (all default to True; set to "false" via env var to disable)
    FLAG_PLANS: bool = True
    FLAG_ANALYSIS: bool = True
    FLAG_SORENESS: bool = True
    FLAG_PR_BOARD: bool = True
    FLAG_DATA_EXPORT: bool = True
    FLAG_WEIGHT_SUGGESTION: bool = True
    FLAG_DIAGNOSTICS: bool = True
    FLAG_ADVANCED_ANALYTICS: bool = True

    @property
    def allowed_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


@lru_cache
def get_settings() -> Settings:
    return Settings()

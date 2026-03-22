"""Sentry initialization for the FastAPI backend."""

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.asyncpg import AsyncPGIntegration

from app.config import get_settings


def init_sentry() -> None:
    settings = get_settings()
    dsn = getattr(settings, "SENTRY_DSN", None)
    if not dsn:
        return

    sentry_sdk.init(
        dsn=dsn,
        environment="production" if not settings.DEBUG else "development",
        integrations=[
            FastApiIntegration(transaction_style="endpoint"),
            AsyncPGIntegration(),
        ],
        # Performance: capture 20% of transactions
        traces_sample_rate=0.2 if not settings.DEBUG else 1.0,
        # Send PII (user IDs) for debugging — no passwords or tokens
        send_default_pii=True,
        # Filter out health check noise
        before_send=_before_send,
    )


def _before_send(event: dict, hint: dict) -> dict | None:
    # Don't send health check errors
    if event.get("request", {}).get("url", "").endswith("/health"):
        return None
    return event

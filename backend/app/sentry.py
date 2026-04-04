"""Sentry initialization for the FastAPI backend."""

from typing import Any

import sentry_sdk
from sentry_sdk.integrations.asyncpg import AsyncPGIntegration
from sentry_sdk.integrations.fastapi import FastApiIntegration

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
        # PII sending disabled to protect user data
        send_default_pii=False,
        # Filter out health check noise
        before_send=_before_send,
    )


def _before_send(event: dict[str, Any], hint: dict[str, Any]) -> dict[str, Any] | None:
    # Don't send health check errors
    if event.get("request", {}).get("url", "").endswith("/health"):
        return None
    return event

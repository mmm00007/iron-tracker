"""Acute:Chronic Workload Ratio (ACWR) — injury risk monitoring.

The ACWR is the gold standard in sports medicine for monitoring training load
and injury risk (Gabbett 2016, Hulin et al. 2014). It compares recent training
stress (acute load, last 7 days) against the athlete's prepared-for baseline
(chronic load, rolling 28-day average).

Uses the exponentially weighted moving average (EWMA) variant which is more
responsive to day-to-day fluctuations than the simple rolling average
(Williams et al. 2017).

Risk zones:
  <0.8  — under-prepared (detraining risk, also elevated injury risk)
  0.8–1.3 — sweet spot (optimal training stimulus)
  1.3–1.5 — caution zone (moderate spike risk)
  >1.5  — danger zone (high injury risk from training spike)
"""

from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import ACWRResponse, ACWRWeeklyEntry

# EWMA decay constants (Williams et al. 2017)
# Lambda = 2 / (N + 1) where N is the time window in days
_ACUTE_LAMBDA = 2 / (7 + 1)   # 7-day window
_CHRONIC_LAMBDA = 2 / (28 + 1)  # 28-day window


def _classify_acwr(ratio: float) -> str:
    """Classify ACWR into risk zone."""
    # ACWR zones per Gabbett (2016), Blanch & Gabbett (2016)
    if ratio < 0.8:
        return "under_prepared"
    if ratio <= 1.3:
        return "optimal"
    if ratio <= 1.5:
        return "caution"
    return "danger"


def _risk_label(zone: str) -> str:
    labels = {
        "under_prepared": "Undertrained — fitness is declining; gradually increase load",
        "optimal": "Sweet spot — training load well matched to fitness",
        "caution": "Moderate spike — monitor closely for signs of overreaching",
        "danger": "High spike risk — consider reducing load to prevent injury",
    }
    return labels.get(zone, "")


async def compute_acwr(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> ACWRResponse:
    """Compute ACWR using EWMA method over the last 56 days.

    Returns the current ACWR ratio, risk zone, weekly trend,
    and per-day acute/chronic loads for the last 4 weeks.
    """
    lookback = datetime.now(UTC) - timedelta(days=56)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(logged_at)       AS day,
                SUM(weight * reps)    AS daily_volume
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND weight > 0
              AND reps > 0
            GROUP BY DATE(logged_at)
            ORDER BY DATE(logged_at)
            """,
            user_id,
            lookback,
        )

    if not rows:
        return ACWRResponse(
            acwr=None,
            risk_zone="insufficient_data",
            risk_description="Need at least 4 weeks of training data to compute ACWR.",
            weekly_trend=[],
            acute_load=0.0,
            chronic_load=0.0,
        )

    # Build complete daily series (including rest days as 0)
    day_volumes: dict[date, float] = {row["day"]: float(row["daily_volume"]) for row in rows}
    first_day = min(day_volumes.keys())
    last_day = date.today()

    daily_loads: list[tuple[date, float]] = []
    current = first_day
    while current <= last_day:
        daily_loads.append((current, day_volumes.get(current, 0.0)))
        current += timedelta(days=1)

    if len(daily_loads) < 14:
        return ACWRResponse(
            acwr=None,
            risk_zone="insufficient_data",
            risk_description="Need at least 2 weeks of data for reliable ACWR.",
            weekly_trend=[],
            acute_load=0.0,
            chronic_load=0.0,
        )

    # Compute EWMA for acute and chronic loads
    # Initialize with mean of first 7 days to avoid single-point bias
    # (data science expert recommendation — single-point initialization
    # heavily biases early EWMA, especially the chronic component).
    init_window = min(7, len(daily_loads))
    init_mean = sum(load for _, load in daily_loads[:init_window]) / init_window
    acute_ewma = init_mean
    chronic_ewma = init_mean
    daily_acwr: list[tuple[date, float, float, float | None]] = []

    for day, load in daily_loads:
        acute_ewma = load * _ACUTE_LAMBDA + acute_ewma * (1 - _ACUTE_LAMBDA)
        chronic_ewma = load * _CHRONIC_LAMBDA + chronic_ewma * (1 - _CHRONIC_LAMBDA)
        ratio = round(acute_ewma / chronic_ewma, 2) if chronic_ewma > 0 else None
        daily_acwr.append((day, acute_ewma, chronic_ewma, ratio))

    # Current values (last day)
    _, current_acute, current_chronic, current_ratio = daily_acwr[-1]

    # Weekly trend (last 8 weeks, using end-of-week ACWR)
    weekly_trend: list[ACWRWeeklyEntry] = []
    today = date.today()
    for w in range(8):
        week_end = today - timedelta(days=today.weekday() + 7 * (7 - w))
        week_start = week_end - timedelta(days=6)
        # Find closest day in our data to the week end
        week_entries = [
            (d, a, c, r) for d, a, c, r in daily_acwr
            if week_start <= d <= week_end
        ]
        if week_entries:
            last_entry = week_entries[-1]
            week_vol = sum(
                day_volumes.get(week_start + timedelta(days=i), 0.0)
                for i in range(7)
            )
            weekly_trend.append(
                ACWRWeeklyEntry(
                    week_start=str(week_start),
                    week_end=str(week_end),
                    acwr=last_entry[3],
                    acute_load=round(last_entry[1], 1),
                    chronic_load=round(last_entry[2], 1),
                    weekly_volume=round(week_vol),
                )
            )

    risk_zone = _classify_acwr(current_ratio) if current_ratio is not None else "insufficient_data"

    return ACWRResponse(
        acwr=current_ratio,
        risk_zone=risk_zone,
        risk_description=_risk_label(risk_zone),
        weekly_trend=weekly_trend,
        acute_load=round(current_acute, 1),
        chronic_load=round(current_chronic, 1),
    )

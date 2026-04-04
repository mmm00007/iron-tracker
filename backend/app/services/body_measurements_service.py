"""Body measurements analytics: circumference and skinfold tracking with trends.

Tracks circumference (neck, shoulder, chest, arm, forearm, waist, hip, thigh, calf)
and skinfold measurements over time. Computes per-site linear trend slopes and
bilateral asymmetry for sites measured on both sides.

Key computations:
  Trend slope: linear regression on (timestamp, value), reported as unit/week
  Asymmetry: abs(left - right) / max(left, right) * 100
  Unit normalization: inches converted to cm (* 2.54) for internal math

Domain expert validations:
  - Fitness: Site list, bilateral comparison logic
  - Sports medicine: Disclaimer text, measurement consistency guidance
  - Data science: Linear regression for trend, cold-start handling
"""

from datetime import UTC, datetime, timedelta
from typing import Any

import asyncpg

from app.models.schemas import (
    BilateralMeasurementEntry,
    BodyMeasurementsResponse,
    MeasurementSiteEntry,
)

_IN_TO_CM = 2.54
_SECONDS_PER_WEEK = 7 * 24 * 3600

_DISCLAIMER = (
    "Body measurements are most reliable when taken consistently by the same "
    "person using the same technique. Skinfold measurements require consistent "
    "caliper technique for accuracy."
)


def _to_cm(value: float, unit: str) -> float:
    """Convert a measurement value to centimetres for internal computation."""
    if unit == "in":
        return value * _IN_TO_CM
    return value


def _linear_slope(timestamps: list[float], values: list[float]) -> float | None:
    """Compute the slope of a simple linear regression (value vs time).

    Returns the slope in value-units per week, or None if fewer than 2 points
    or zero variance in timestamps.
    """
    n = len(timestamps)
    if n < 2:
        return None

    sum_t = sum(timestamps)
    sum_v = sum(values)
    sum_tv = sum(t * v for t, v in zip(timestamps, values))
    sum_tt = sum(t * t for t in timestamps)

    denom = n * sum_tt - sum_t * sum_t
    if denom == 0:
        return None

    # Slope in value-units per second, then convert to per week
    slope_per_sec = (n * sum_tv - sum_t * sum_v) / denom
    return slope_per_sec * _SECONDS_PER_WEEK


async def compute_body_measurements(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 180,
) -> BodyMeasurementsResponse:
    """Compute body measurement analytics for a user.

    Groups measurements by site, computes latest values and trend slopes via
    linear regression. For bilateral sites (left/right), computes asymmetry
    from the most recent same-date pair.

    Cold start: returns empty lists when no data exists. Sites with a single
    measurement show the latest value but no trend slope.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        # All measurements in the period for trend computation
        trend_rows = await conn.fetch(
            """
            SELECT site, side, measurement_type, value::float, unit,
                   measured_at::text,
                   EXTRACT(EPOCH FROM measured_at) AS ts
            FROM body_measurements
            WHERE user_id = $1 AND measured_at >= $2
            ORDER BY site, side, measured_at ASC
            """,
            user_id,
            since,
        )

        # Latest bilateral pairs (same date, both sides present)
        bilateral_rows = await conn.fetch(
            """
            SELECT bm.site, bm.side, bm.value::float, bm.unit
            FROM body_measurements bm
            WHERE bm.user_id = $1
              AND bm.side IS NOT NULL
              AND bm.measured_at = (
                SELECT MAX(measured_at) FROM body_measurements
                WHERE user_id = $1 AND site = bm.site AND side IS NOT NULL
              )
            ORDER BY bm.site, bm.side
            """,
            user_id,
        )

    # --- Cold start: no data ---
    if not trend_rows:
        return BodyMeasurementsResponse(
            sites=[],
            bilateral=[],
            total_measurements=0,
            sites_tracked=0,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # --- Group by (site, side) for per-site trend analysis ---
    # Key: (site, side_or_none) -> list of (ts, value_cm, original_value, unit, type)
    site_data: dict[tuple[str, str | None], list[dict[str, Any]]] = {}
    for row in trend_rows:
        key = (row["site"], row["side"])
        if key not in site_data:
            site_data[key] = []
        site_data[key].append(
            {
                "ts": float(row["ts"]),
                "value": float(row["value"]),
                "unit": row["unit"],
                "measurement_type": row["measurement_type"],
            }
        )

    # --- Build per-site entries (collapse left/right into one site key) ---
    # For sites with sides, we merge data points and use the latest from either
    # side for the headline value. For sites without sides, use directly.
    site_entries_map: dict[str, dict[str, Any]] = {}

    for (site, side), records in site_data.items():
        if site not in site_entries_map:
            site_entries_map[site] = {
                "measurement_type": records[0]["measurement_type"],
                "timestamps": [],
                "values_cm": [],
                "latest_value": records[-1]["value"],
                "unit": records[-1]["unit"],
                "data_points": 0,
            }

        entry = site_entries_map[site]
        for rec in records:
            entry["timestamps"].append(rec["ts"])
            entry["values_cm"].append(_to_cm(rec["value"], rec["unit"]))
            entry["data_points"] += 1

        # Keep the most recent value across all sides
        if records[-1]["ts"] >= entry["timestamps"][-1]:
            entry["latest_value"] = records[-1]["value"]
            entry["unit"] = records[-1]["unit"]

    sites: list[MeasurementSiteEntry] = []
    for site, entry in sorted(site_entries_map.items()):
        slope = _linear_slope(entry["timestamps"], entry["values_cm"])

        # Convert slope back to the display unit if original was inches
        if slope is not None and entry["unit"] == "in":
            slope = slope / _IN_TO_CM

        sites.append(
            MeasurementSiteEntry(
                site=site,
                measurement_type=entry["measurement_type"],
                latest_value=round(entry["latest_value"], 1),
                unit=entry["unit"],
                trend_slope=round(slope, 3) if slope is not None else None,
                data_points=entry["data_points"],
            )
        )

    # --- Bilateral comparison ---
    bilateral: list[BilateralMeasurementEntry] = []

    # Group bilateral rows by site, expecting left + right pairs
    bilateral_by_site: dict[str, dict[str, dict[str, Any]]] = {}
    for row in bilateral_rows:
        site = row["site"]
        side = row["side"]
        if side is None:
            continue
        if site not in bilateral_by_site:
            bilateral_by_site[site] = {}
        bilateral_by_site[site][side.lower()] = {
            "value": float(row["value"]),
            "unit": row["unit"],
        }

    for site in sorted(bilateral_by_site):
        sides = bilateral_by_site[site]
        if "left" not in sides or "right" not in sides:
            continue

        left_val = sides["left"]["value"]
        right_val = sides["right"]["value"]
        unit = sides["left"]["unit"]

        max_val = max(left_val, right_val)
        if max_val == 0:
            continue

        asymmetry_pct = abs(left_val - right_val) / max_val * 100

        bilateral.append(
            BilateralMeasurementEntry(
                site=site,
                left_value=round(left_val, 1),
                right_value=round(right_val, 1),
                unit=unit,
                asymmetry_pct=round(asymmetry_pct, 1),
            )
        )

    total_measurements = len(trend_rows)
    sites_tracked = len(site_entries_map)

    return BodyMeasurementsResponse(
        sites=sites,
        bilateral=bilateral,
        total_measurements=total_measurements,
        sites_tracked=sites_tracked,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

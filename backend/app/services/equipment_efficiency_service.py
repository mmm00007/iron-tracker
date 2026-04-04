"""Equipment efficiency analysis across equipment variants.

Compares user performance across different equipment variants (machines,
barbells, dumbbells, cables, etc.) to identify which equipment produces
the best strength gains.

Per variant:
1. Best estimated 1RM across the analysis period
2. Set count in the last 30 days (recent usage)
3. Number of distinct training sessions
4. User rating (from equipment_variants table)
5. e1RM trend slope via linear regression on daily best e1RM

Top performer = variant with the highest positive e1RM trend slope,
indicating the equipment driving the most consistent strength gains.

Cold start: requires >= 4 sessions per variant to compute trend slope.
Variants below that threshold still appear with usage stats but without
a trend value.
"""

from datetime import UTC, datetime, timedelta
from typing import Any

import asyncpg

from app.models.schemas import (
    EquipmentEfficiencyEntry,
    EquipmentEfficiencyResponse,
)
from app.services.utils import linear_regression_slope as _linear_regression

_DISCLAIMER = (
    "Equipment efficiency reflects your personal performance across "
    "different machines and equipment. Past performance does not "
    "guarantee future results."
)


async def compute_equipment_efficiency(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> EquipmentEfficiencyResponse:
    """Analyze per-variant equipment efficiency over the given period.

    Returns usage stats, best e1RM, and trend slope for every equipment
    variant the user has logged working/backoff/failure sets on.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)
    thirty_days_ago = datetime.now(UTC) - timedelta(days=30)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                ev.id::text      AS variant_id,
                ev.name           AS variant_name,
                ev.equipment_type,
                ev.rating,
                s.training_date::text AS training_date,
                MAX(s.estimated_1rm)  AS best_e1rm,
                COUNT(*)              AS set_count
            FROM sets s
            JOIN equipment_variants ev ON ev.id = s.variant_id
            WHERE s.user_id = $1
              AND s.variant_id IS NOT NULL
              AND s.logged_at >= $2
              AND s.set_type IN ('working', 'backoff', 'failure')
              AND s.estimated_1rm > 0
            GROUP BY ev.id, ev.name, ev.equipment_type, ev.rating,
                     s.training_date
            ORDER BY ev.id, s.training_date ASC
            """,
            user_id,
            since,
        )

    if not rows:
        return EquipmentEfficiencyResponse(
            equipment=[],
            total_variants_used=0,
            top_performer=None,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # ── Group rows by variant ────────────────────────────────────────────
    variant_data: dict[str, dict[str, Any]] = {}
    for row in rows:
        vid = row["variant_id"]
        if vid not in variant_data:
            variant_data[vid] = {
                "variant_name": row["variant_name"],
                "equipment_type": row["equipment_type"],
                "rating": row["rating"],
                "daily_bests": {},  # training_date -> best_e1rm
            }
        date_str = row["training_date"]
        e1rm = float(row["best_e1rm"])
        current = variant_data[vid]["daily_bests"].get(date_str, 0.0)
        if e1rm > current:
            variant_data[vid]["daily_bests"][date_str] = e1rm

    # ── Build entries ────────────────────────────────────────────────────
    entries: list[EquipmentEfficiencyEntry] = []
    best_slope: float | None = None
    best_slope_name: str | None = None

    for vid, data in variant_data.items():
        daily_bests = data["daily_bests"]
        sorted_dates = sorted(daily_bests.keys())

        best_e1rm = max(daily_bests.values())
        sessions_used = len(sorted_dates)

        # Sets in last 30 days: count dates within the window
        thirty_day_str = thirty_days_ago.strftime("%Y-%m-%d")
        sets_30d = sum(1 for d in sorted_dates if d >= thirty_day_str)

        # e1RM trend slope (requires >= 4 sessions)
        if sessions_used >= 4:
            # Use date index (days since first session) as x-axis
            origin = sorted_dates[0]
            xs: list[float] = []
            ys: list[float] = []
            for d in sorted_dates:
                day_offset = (
                    datetime.strptime(d, "%Y-%m-%d") - datetime.strptime(origin, "%Y-%m-%d")
                ).days
                xs.append(float(day_offset))
                ys.append(daily_bests[d])
            slope = _linear_regression(xs, ys)
        else:
            slope = None

        # Track top performer (highest positive slope)
        if slope is not None and slope > 0:
            if best_slope is None or slope > best_slope:
                best_slope = slope
                best_slope_name = data["variant_name"]

        entries.append(
            EquipmentEfficiencyEntry(
                variant_id=vid,
                variant_name=data["variant_name"],
                equipment_type=data["equipment_type"],
                rating=data["rating"],
                sets_30d=sets_30d,
                best_e1rm=round(best_e1rm, 1),
                e1rm_trend_slope=round(slope, 4) if slope is not None else None,
                sessions_used=sessions_used,
            )
        )

    # Sort: variants with trend data first (by slope desc), then by best_e1rm
    entries.sort(
        key=lambda e: (
            e.e1rm_trend_slope is None,
            -(e.e1rm_trend_slope or 0.0),
            -e.best_e1rm,
        )
    )

    return EquipmentEfficiencyResponse(
        equipment=entries,
        total_variants_used=len(entries),
        top_performer=best_slope_name,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

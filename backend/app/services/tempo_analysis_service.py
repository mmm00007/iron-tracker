"""Tempo analysis: time-under-tension distribution and coverage metrics."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import TempoAnalysisResponse, TempoDistributionEntry

_COLD_START_THRESHOLD = 10

_TUT_CATEGORIES: list[tuple[str, str, float, float]] = [
    ("strength", "<20s", 0, 20),
    ("moderate", "20-40s", 20, 40),
    ("hypertrophy", "40-60s", 40, 60),
    ("endurance", ">60s", 60, float("inf")),
]

_DISCLAIMER = (
    "Time under tension is one of many training variables. "
    "Load and volume remain the primary drivers of adaptation."
)


def _parse_tempo(tempo: str) -> tuple[int, int, int, int] | None:
    """Parse a tempo string like '3010' into (eccentric, pause_bottom, concentric, pause_top).

    Handles 'X' as explosive (~1 second) and ignores non-digit, non-X characters.
    Returns None if the string does not yield exactly 4 digits.
    """
    if not tempo or not tempo.strip():
        return None
    cleaned = tempo.strip().upper()
    digits: list[int] = []
    for ch in cleaned:
        if ch.isdigit():
            digits.append(int(ch))
        elif ch == "X":
            digits.append(1)  # Explosive = ~1 second
        else:
            continue
    if len(digits) != 4:
        return None
    return (digits[0], digits[1], digits[2], digits[3])


def _compute_tut(tempo: tuple[int, int, int, int], reps: int) -> float:
    """Compute time under tension in seconds: sum of tempo phases * reps."""
    return sum(tempo) * reps


def _classify_tut(tut_seconds: float) -> str:
    """Return the TUT category name for the given duration."""
    for name, _, lower, upper in _TUT_CATEGORIES:
        if lower <= tut_seconds < upper:
            return name
    return "endurance"  # Fallback for exactly 60s edge case


async def compute_tempo_analysis(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> TempoAnalysisResponse:
    """Compute tempo / time-under-tension analysis over the given period.

    Steps:
    1. Query all sets with reps > 0, partitioning into tempo-logged and total.
    2. Parse tempo strings and compute per-set TUT.
    3. Classify TUT into strength / moderate / hypertrophy / endurance buckets.
    4. Return distribution percentages and tempo coverage.

    Cold start: fewer than 10 sets with tempo returns raw counts with
    avg_tut_seconds set to None.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT s.tempo, s.reps, s.set_type
            FROM sets s
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.reps > 0
            """,
            user_id,
            since,
        )

    # Count totals for coverage calculation
    total_sets = len(rows)
    sets_with_tempo: list[tuple[tuple[int, int, int, int], int]] = []

    for row in rows:
        raw_tempo = row["tempo"]
        if raw_tempo is None:
            continue
        parsed = _parse_tempo(str(raw_tempo))
        if parsed is None:
            continue
        sets_with_tempo.append((parsed, int(row["reps"])))

    tempo_count = len(sets_with_tempo)
    tempo_coverage_pct = round(
        (tempo_count / total_sets * 100) if total_sets > 0 else 0.0, 1
    )

    # Cold start: not enough tempo data for meaningful analysis
    if tempo_count < _COLD_START_THRESHOLD:
        # Build distribution with zero counts
        distribution = [
            TempoDistributionEntry(
                category=name,
                tut_range=tut_range,
                set_count=0,
                percentage=0.0,
            )
            for name, tut_range, _, _ in _TUT_CATEGORIES
        ]
        return TempoAnalysisResponse(
            avg_tut_seconds=None,
            distribution=distribution,
            tempo_coverage_pct=tempo_coverage_pct,
            sets_with_tempo=tempo_count,
            total_sets=total_sets,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # Compute TUT for each set and classify
    tut_values: list[float] = []
    category_counts: dict[str, int] = {name: 0 for name, _, _, _ in _TUT_CATEGORIES}

    for parsed_tempo, reps in sets_with_tempo:
        tut = _compute_tut(parsed_tempo, reps)
        tut_values.append(tut)
        category = _classify_tut(tut)
        category_counts[category] += 1

    avg_tut_seconds = round(sum(tut_values) / len(tut_values), 1)

    # Build distribution with percentages
    distribution = [
        TempoDistributionEntry(
            category=name,
            tut_range=tut_range,
            set_count=category_counts[name],
            percentage=round(category_counts[name] / tempo_count * 100, 1),
        )
        for name, tut_range, _, _ in _TUT_CATEGORIES
    ]

    return TempoAnalysisResponse(
        avg_tut_seconds=avg_tut_seconds,
        distribution=distribution,
        tempo_coverage_pct=tempo_coverage_pct,
        sets_with_tempo=tempo_count,
        total_sets=total_sets,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )

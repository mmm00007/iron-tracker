"""Shared utility functions for analytics services.

Avoids duplicating common formulas (Epley 1RM, linear regression) across
multiple service modules.
"""


def epley(weight: float, reps: int) -> float:
    """Epley formula: weight x (1 + reps / 30). Returns estimated 1RM.

    For 1-rep sets, returns weight directly (that IS the 1RM).
    Reps clamped to 12 — Epley degrades significantly above 12 reps
    (Mayhew et al. 1995, error >10%).
    """
    if weight <= 0 or reps <= 0:
        return 0.0
    if reps == 1:
        return weight
    effective_reps = min(reps, 12)
    return weight * (1 + effective_reps / 30)


def linear_regression(
    xs: list[float],
    ys: list[float],
    min_points: int = 2,
) -> tuple[float | None, float | None]:
    """Pure-Python OLS linear regression.

    Returns (slope, intercept), or (None, None) if fewer than *min_points*
    data points or zero variance in *xs*.
    """
    n = len(xs)
    if n < min_points:
        return None, None

    x_mean = sum(xs) / n
    y_mean = sum(ys) / n
    num = sum((x - x_mean) * (y - y_mean) for x, y in zip(xs, ys))
    den = sum((x - x_mean) ** 2 for x in xs)

    if den == 0:
        return 0.0, y_mean

    slope = num / den
    intercept = y_mean - slope * x_mean
    return slope, intercept


def theil_sen_slope(
    xs: list[float],
    ys: list[float],
    min_points: int = 3,
) -> float | None:
    """Theil-Sen slope estimator — median of all pairwise slopes.

    Resistant to up to ~29% outliers, unlike OLS which is distorted by a
    single bad data point. Preferred for e1RM trend estimation where a
    mislogged weight can flip the apparent trend direction.
    """
    n = len(xs)
    if n < min_points:
        return None

    slopes: list[float] = []
    for i in range(n):
        for j in range(i + 1, n):
            dx = xs[j] - xs[i]
            if dx != 0:
                slopes.append((ys[j] - ys[i]) / dx)

    if not slopes:
        return 0.0

    slopes.sort()
    mid = len(slopes) // 2
    if len(slopes) % 2 == 0:
        return (slopes[mid - 1] + slopes[mid]) / 2
    return slopes[mid]


def linear_regression_slope(
    xs: list[float],
    ys: list[float],
    min_points: int = 4,
) -> float | None:
    """Convenience wrapper that returns only the slope, or None."""
    slope, _ = linear_regression(xs, ys, min_points=min_points)
    return slope

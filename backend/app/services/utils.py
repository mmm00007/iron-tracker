"""Shared utility functions for analytics services.

Avoids duplicating common formulas (Epley 1RM, linear regression) across
multiple service modules.
"""


def epley(weight: float, reps: int) -> float:
    """Epley formula: weight x (1 + reps / 30). Returns estimated 1RM.

    For 1-rep sets, returns weight directly (that IS the 1RM).
    """
    if reps <= 1 or weight <= 0:
        return weight
    return weight * (1 + reps / 30)


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


def linear_regression_slope(
    xs: list[float],
    ys: list[float],
    min_points: int = 4,
) -> float | None:
    """Convenience wrapper that returns only the slope, or None."""
    slope, _ = linear_regression(xs, ys, min_points=min_points)
    return slope

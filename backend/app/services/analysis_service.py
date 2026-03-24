import json
import logging
import uuid
from datetime import datetime

import anthropic
import asyncpg

logger = logging.getLogger(__name__)


async def analyze_training(
    db_pool: asyncpg.Pool,
    user_id: str,
    api_key: str,
    scope_type: str,
    scope_start: str,
    scope_end: str,
    goals: list[str],
) -> dict:
    """Generate AI training analysis for a date range."""

    # Fetch sets in scope
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT s.weight, s.reps, s.rpe, s.set_type, s.logged_at, s.weight_unit,
                   e.name AS exercise_name, e.category
            FROM sets s
            JOIN exercises e ON s.exercise_id = e.id
            WHERE s.user_id = $1
              AND s.logged_at::date >= $2::date
              AND s.logged_at::date <= $3::date
            ORDER BY s.logged_at
            """,
            user_id,
            scope_start,
            scope_end,
        )

    if not rows:
        return {
            "id": str(uuid.uuid4()),
            "summary": "No training data found for this period.",
            "insights": [],
            "created_at": datetime.utcnow().isoformat(),
        }

    # Build context for Claude
    total_sets = len(rows)
    total_volume = sum(r["weight"] * r["reps"] for r in rows)
    training_days = len(set(r["logged_at"].strftime("%Y-%m-%d") for r in rows))
    exercises = {}
    for r in rows:
        name = r["exercise_name"]
        if name not in exercises:
            exercises[name] = {"sets": 0, "volume": 0, "category": r["category"]}
        exercises[name]["sets"] += 1
        exercises[name]["volume"] += r["weight"] * r["reps"]

    context = (
        f"Training period: {scope_start} to {scope_end}\n"
        f"Total sets: {total_sets}, Total volume: {total_volume:.0f}, Training days: {training_days}\n"
        f"Goals: {', '.join(goals) if goals else 'general fitness'}\n\n"
        f"Exercise breakdown:\n"
    )
    for name, data in sorted(exercises.items(), key=lambda x: -x[1]["volume"]):
        context += (
            f"- {name} ({data['category']}): {data['sets']} sets, {data['volume']:.0f} volume\n"
        )

    # Call Claude
    client = anthropic.AsyncAnthropic(api_key=api_key)
    system_prompt = (
        "You are a fitness coach analyzing training data. "
        "Provide a brief summary and 3-5 specific, actionable insights. "
        "Each insight must include: metric (what you measured), finding (what you observed), "
        "delta (change vs expected, if applicable), and recommendation (what to do). "
        "Return ONLY valid JSON with this schema: "
        '{"summary": "...", "insights": [{"metric": "...", "finding": "...", "delta": "...", "recommendation": "..."}]}'
    )

    response = await client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        system=system_prompt,
        messages=[{"role": "user", "content": context}],
    )

    # Parse response
    raw_text = response.content[0].text.strip()
    # Strip markdown fences if present
    if raw_text.startswith("```"):
        raw_text = raw_text.split("\n", 1)[1] if "\n" in raw_text else raw_text[3:]
    if raw_text.endswith("```"):
        raw_text = raw_text[:-3].strip()

    try:
        result = json.loads(raw_text)
    except json.JSONDecodeError:
        logger.warning("Failed to parse AI analysis response: %s", raw_text[:200])
        result = {
            "summary": raw_text[:500],
            "insights": [],
        }

    # Validate insights — drop any that don't have the required fields
    validated_insights = []
    for raw_insight in result.get("insights", []):
        if (
            isinstance(raw_insight, dict)
            and "metric" in raw_insight
            and "finding" in raw_insight
            and "recommendation" in raw_insight
        ):
            validated_insights.append(
                {
                    "metric": str(raw_insight["metric"]),
                    "finding": str(raw_insight["finding"]),
                    "delta": str(raw_insight["delta"]) if raw_insight.get("delta") else None,
                    "recommendation": str(raw_insight["recommendation"]),
                }
            )
    result["insights"] = validated_insights

    report_id = str(uuid.uuid4())

    # Store in database
    async with db_pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO analysis_reports (id, user_id, scope_type, scope_start, scope_end, goals, summary, insights)
            VALUES ($1, $2, $3, $4::date, $5::date, $6, $7, $8::jsonb)
            """,
            report_id,
            user_id,
            scope_type,
            scope_start,
            scope_end,
            goals,
            result.get("summary", ""),
            json.dumps(result.get("insights", [])),
        )

    return {
        "id": report_id,
        "summary": result.get("summary", ""),
        "insights": result.get("insights", []),
        "created_at": datetime.utcnow().isoformat(),
    }

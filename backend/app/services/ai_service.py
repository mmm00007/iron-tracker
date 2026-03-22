import base64
import json
import logging

import anthropic

from app.models.schemas import MachineIdentificationResponse, TargetMuscles

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are an expert gym equipment identifier with deep knowledge of exercise science and biomechanics.

When given an image, analyze it and respond ONLY with a valid JSON object — no markdown fences, no extra text.

If the image contains gym equipment or an exercise machine, return:
{
  "exercise_names": ["Primary Exercise", "Secondary Exercise"],
  "equipment_type": "machine_selectorized",
  "manufacturer": "Life Fitness",
  "target_muscles": {
    "primary": ["quadriceps", "glutes"],
    "secondary": ["hamstrings", "calves"]
  },
  "form_tips": [
    "Adjust seat so knees align with pivot point",
    "Keep feet flat on the platform, shoulder-width apart",
    "Lower weight under control, avoid locking knees at the top",
    "Exhale during the push phase, inhale on the way down"
  ],
  "confidence": "high"
}

Rules:
- exercise_names: list all exercises the machine supports (1-4 entries)
- equipment_type: one of machine_selectorized | machine_plate | cable | barbell | dumbbell | bodyweight | smith_machine | other
- manufacturer: brand visible on the equipment, or null if not identifiable
- target_muscles: use common anatomical names (e.g., quadriceps, pectoralis major, latissimus dorsi)
- form_tips: 3-4 concise, actionable safety and effectiveness tips
- confidence: "high" if clearly identifiable, "medium" if partially visible or ambiguous, "low" if a best guess

If the image does NOT contain gym equipment (e.g., it shows a person, food, landscape, etc.), return:
{
  "exercise_names": [],
  "equipment_type": "other",
  "manufacturer": null,
  "target_muscles": {"primary": [], "secondary": []},
  "form_tips": [],
  "confidence": "low",
  "error": "No gym equipment detected in this image."
}

Respond ONLY with valid JSON."""


class AIService:
    def __init__(self, api_key: str) -> None:
        self.client = anthropic.Anthropic(api_key=api_key)

    async def identify_machine(
        self,
        image_bytes: bytes,
        content_type: str,
    ) -> MachineIdentificationResponse:
        """Send gym equipment image to Claude Sonnet for identification."""
        image_data = base64.standard_b64encode(image_bytes).decode("utf-8")

        # Map content_type to Anthropic's accepted media types
        # Valid values: image/jpeg | image/png | image/gif | image/webp
        media_type_map: dict[str, str] = {
            "image/jpeg": "image/jpeg",
            "image/jpg": "image/jpeg",
            "image/png": "image/png",
            "image/gif": "image/gif",
            "image/webp": "image/webp",
        }
        media_type = media_type_map.get(content_type.lower(), "image/jpeg")

        try:
            message = self.client.messages.create(
                model="claude-sonnet-4-5-20250514",
                max_tokens=1024,
                system=SYSTEM_PROMPT,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": media_type,
                                    "data": image_data,
                                },
                            },
                            {
                                "type": "text",
                                "text": "Identify this gym equipment and return the JSON response.",
                            },
                        ],
                    }
                ],
            )
        except anthropic.APIError as exc:
            logger.error("Anthropic API error during machine identification: %s", exc)
            raise

        response_text = message.content[0].text
        # Strip markdown fences in case the model wraps its output
        stripped = response_text.strip()
        if stripped.startswith("```"):
            lines = stripped.splitlines()
            stripped = "\n".join(lines[1:-1]) if len(lines) > 2 else stripped

        try:
            data = json.loads(stripped)
        except json.JSONDecodeError as exc:
            logger.error("Failed to parse AI response as JSON: %s\nResponse: %s", exc, response_text)
            # Return a graceful fallback
            return MachineIdentificationResponse(
                exercise_names=[],
                equipment_type="other",
                manufacturer=None,
                target_muscles=TargetMuscles(primary=[], secondary=[]),
                form_tips=[],
                confidence="low",
            )

        raw_muscles = data.get("target_muscles", {})
        if isinstance(raw_muscles, dict):
            target_muscles = TargetMuscles(
                primary=raw_muscles.get("primary", []),
                secondary=raw_muscles.get("secondary", []),
            )
        else:
            # Gracefully handle legacy flat list format
            target_muscles = TargetMuscles(primary=list(raw_muscles), secondary=[])

        return MachineIdentificationResponse(
            exercise_names=data.get("exercise_names", []),
            equipment_type=data.get("equipment_type", "other"),
            manufacturer=data.get("manufacturer"),
            target_muscles=target_muscles,
            form_tips=data.get("form_tips", []),
            confidence=data.get("confidence", "low"),
        )

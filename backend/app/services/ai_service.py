import base64

import anthropic

from app.models.schemas import MachineIdentificationResponse

SYSTEM_PROMPT = """You are an expert gym equipment identifier. When given an image of gym equipment or a exercise machine, analyze it and respond with a JSON object containing:
- exercise_name: The primary exercise this machine is used for (e.g., "Leg Press", "Lat Pulldown")
- equipment_type: The category of equipment (e.g., "Cable Machine", "Free Weight", "Smith Machine", "Plate-Loaded", "Selectorized")
- manufacturer: The brand/manufacturer if visible, otherwise null
- muscles: A list of primary and secondary muscle groups targeted (e.g., ["quadriceps", "glutes", "hamstrings"])
- form_tips: A list of 2-4 key form tips for safe and effective use

Respond ONLY with valid JSON, no additional text."""


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
        media_type_map = {
            "image/jpeg": "image/jpeg",
            "image/jpg": "image/jpeg",
            "image/png": "image/png",
            "image/gif": "image/gif",
            "image/webp": "image/webp",
        }
        media_type = media_type_map.get(content_type.lower(), "image/jpeg")

        message = self.client.messages.create(
            model="claude-sonnet-4-5",
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
                            "text": "Please identify this gym equipment and provide the details.",
                        },
                    ],
                }
            ],
        )

        import json

        response_text = message.content[0].text
        data = json.loads(response_text)

        return MachineIdentificationResponse(
            exercise_name=data.get("exercise_name", "Unknown"),
            equipment_type=data.get("equipment_type", "Unknown"),
            manufacturer=data.get("manufacturer"),
            muscles=data.get("muscles", []),
            form_tips=data.get("form_tips", []),
        )

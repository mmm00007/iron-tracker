from fastapi import APIRouter, Depends, HTTPException, UploadFile, status

from app.auth import get_current_user
from app.config import Settings, get_settings
from app.models.schemas import MachineIdentificationResponse
from app.services.ai_service import AIService

router = APIRouter(prefix="/api/ai", tags=["ai"])

# Simple in-memory rate limit tracker: {user_id: count_today}
# TODO: Replace with Redis or Supabase-backed rate limiting
_rate_limit_store: dict[str, int] = {}

# Image hash cache stub: {image_hash: MachineIdentificationResponse}
_image_cache: dict[str, MachineIdentificationResponse] = {}


def _check_rate_limit(user_id: str, limit: int) -> None:
    """Check if user has exceeded the daily AI request limit."""
    count = _rate_limit_store.get(user_id, 0)
    if count >= limit:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Daily AI request limit of {limit} reached. Try again tomorrow.",
        )
    _rate_limit_store[user_id] = count + 1


@router.post("/identify-machine", response_model=MachineIdentificationResponse)
async def identify_machine(
    image: UploadFile,
    user_id: str = Depends(get_current_user),
    settings: Settings = Depends(get_settings),
) -> MachineIdentificationResponse:
    """Identify gym equipment from an uploaded photo using Claude AI."""
    _check_rate_limit(user_id, settings.AI_RATE_LIMIT_PER_DAY)

    if image.content_type not in ("image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Unsupported image format. Use JPEG, PNG, or WebP.",
        )

    image_bytes = await image.read()

    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Uploaded image is empty.",
        )

    # Image hash caching stub
    import hashlib

    image_hash = hashlib.sha256(image_bytes).hexdigest()
    if image_hash in _image_cache:
        return _image_cache[image_hash]

    ai_service = AIService(api_key=settings.ANTHROPIC_API_KEY)
    result = await ai_service.identify_machine(image_bytes, image.content_type or "image/jpeg")

    _image_cache[image_hash] = result
    return result

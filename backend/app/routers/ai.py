import hashlib
import logging
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status

from app.auth import get_current_user
from app.config import Settings, get_settings
from app.models.schemas import MachineIdentificationResponse
from app.services.ai_service import AIService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/ai", tags=["ai"])

# Allowed image MIME types
_ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/jpg", "image/png", "image/webp"}

# Maximum image size: 5 MB
_MAX_IMAGE_BYTES = 5 * 1024 * 1024

# In-memory rate limit tracker: {user_id: (date_str, count)}
# Resets automatically when the date changes.
_rate_limit_store: dict[str, tuple[str, int]] = {}

# Image hash cache: {image_hash: MachineIdentificationResponse}
_image_cache: dict[str, MachineIdentificationResponse] = {}


def _check_rate_limit(user_id: str, limit: int) -> None:
    """Check if user has exceeded the daily AI request limit.

    Tracks requests per calendar day (UTC). Resets automatically at midnight.
    """
    today = date.today().isoformat()
    entry = _rate_limit_store.get(user_id)

    if entry is None or entry[0] != today:
        # First request today — initialise counter
        _rate_limit_store[user_id] = (today, 1)
        return

    stored_date, count = entry
    if count >= limit:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Daily AI request limit of {limit} reached. Try again tomorrow.",
        )
    _rate_limit_store[user_id] = (stored_date, count + 1)


@router.post("/identify-machine", response_model=MachineIdentificationResponse)
async def identify_machine(
    image: UploadFile,
    user_id: str = Depends(get_current_user),
    settings: Settings = Depends(get_settings),
) -> MachineIdentificationResponse:
    """Identify gym equipment from an uploaded photo using Claude AI.

    Accepts JPEG or PNG images up to 5 MB.  Results are cached by SHA-256
    image hash so identical images are never sent to the AI twice.
    Each authenticated user is limited to AI_RATE_LIMIT_PER_DAY requests per
    calendar day (default 10).
    """
    # --- Rate limiting (checked before reading bytes to fail fast) ---
    _check_rate_limit(user_id, settings.AI_RATE_LIMIT_PER_DAY)

    # --- File type validation ---
    content_type = (image.content_type or "").lower()
    if content_type not in _ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Unsupported image format. Accepted formats: JPEG, PNG, WebP.",
        )

    # --- Read and validate file size ---
    image_bytes = await image.read()

    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Uploaded image is empty.",
        )

    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Image too large. Maximum allowed size is {_MAX_IMAGE_BYTES // (1024 * 1024)} MB.",
        )

    # --- Cache lookup ---
    image_hash = hashlib.sha256(image_bytes).hexdigest()
    if image_hash in _image_cache:
        logger.info("Cache hit for image hash %s (user %s)", image_hash[:12], user_id)
        return _image_cache[image_hash]

    # --- AI identification ---
    ai_service = AIService(api_key=settings.ANTHROPIC_API_KEY)

    try:
        result = await ai_service.identify_machine(image_bytes, content_type)
    except Exception as exc:
        logger.exception("AI service error for user %s: %s", user_id, exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI service temporarily unavailable. Please try again.",
        ) from exc

    # Cache successful result
    _image_cache[image_hash] = result
    return result

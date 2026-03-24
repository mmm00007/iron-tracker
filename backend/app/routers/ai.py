import hashlib
import logging
from collections import OrderedDict
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Request, UploadFile, status

from app.auth import get_current_user
from app.config import Settings, get_settings
from app.models.schemas import AnalysisRequest, AnalysisResponse, MachineIdentificationResponse
from app.services.ai_service import AIService
from app.services.analysis_service import analyze_training

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/ai", tags=["ai"])

# Allowed image MIME types
_ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/jpg", "image/png", "image/webp"}

# Maximum image size: 5 MB
_MAX_IMAGE_BYTES = 5 * 1024 * 1024

# Magic byte signatures for supported image formats
_MAGIC_BYTES = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG": "image/png",
    b"RIFF": "image/webp",
}


def _validate_image_magic(data: bytes) -> bool:
    return any(data.startswith(magic) for magic in _MAGIC_BYTES)


# In-memory rate limit tracker: {user_id: (date_str, count)}
# Resets automatically when the date changes.
_rate_limit_store: dict[str, tuple[str, int]] = {}


class _LRUCache:
    """Bounded LRU cache backed by an OrderedDict."""

    def __init__(self, maxsize: int = 100) -> None:
        self._cache: OrderedDict[str, MachineIdentificationResponse] = OrderedDict()
        self._maxsize = maxsize

    def get(self, key: str) -> MachineIdentificationResponse | None:
        if key in self._cache:
            self._cache.move_to_end(key)
            return self._cache[key]
        return None

    def clear(self) -> None:
        """Remove all entries from the cache."""
        self._cache.clear()

    def set(self, key: str, value: MachineIdentificationResponse) -> None:
        if key in self._cache:
            self._cache.move_to_end(key)
        self._cache[key] = value
        if len(self._cache) > self._maxsize:
            self._cache.popitem(last=False)


# Image hash cache — bounded to 100 entries; oldest entry evicted when full.
_image_cache = _LRUCache(maxsize=100)


def _check_rate_limit(user_id: str, limit: int) -> None:
    """Check if user has exceeded the daily AI request limit.

    Tracks requests per calendar day (UTC). Resets automatically at midnight.
    Purges stale entries from previous days to keep memory bounded.
    """
    today = date.today().isoformat()

    # Evict entries from previous days to prevent unbounded growth.
    stale_keys = [uid for uid, (d, _) in _rate_limit_store.items() if d != today]
    for key in stale_keys:
        del _rate_limit_store[key]

    entry = _rate_limit_store.get(user_id)

    if entry is None:
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

    if not _validate_image_magic(image_bytes):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="File does not appear to be a valid image.",
        )

    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                f"Image too large. Maximum allowed size is {_MAX_IMAGE_BYTES // (1024 * 1024)} MB."
            ),
        )

    # --- Cache lookup ---
    image_hash = hashlib.sha256(image_bytes).hexdigest()
    cached = _image_cache.get(image_hash)
    if cached is not None:
        logger.info("Cache hit for image hash %s (user %s)", image_hash[:12], user_id)
        return cached

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
    _image_cache.set(image_hash, result)
    return result


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_training_data(
    body: AnalysisRequest,
    request: Request,
    user_id: str = Depends(get_current_user),
    settings: Settings = Depends(get_settings),
) -> AnalysisResponse:
    """Generate AI-powered training analysis for a date range.

    Rate limited to 5 requests per user per day.
    """
    _check_rate_limit(user_id, min(settings.AI_RATE_LIMIT_PER_DAY, 5))

    db_pool = getattr(request.app.state, "db_pool", None)
    if db_pool is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database not available",
        )

    try:
        result = await analyze_training(
            db_pool=db_pool,
            user_id=user_id,
            api_key=settings.ANTHROPIC_API_KEY,
            scope_type=body.scope_type,
            scope_start=body.scope_start,
            scope_end=body.scope_end,
            goals=body.goals,
        )
    except Exception as exc:
        logger.exception("Analysis error for user %s: %s", user_id, exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Analysis service temporarily unavailable.",
        ) from exc

    return AnalysisResponse(**result)

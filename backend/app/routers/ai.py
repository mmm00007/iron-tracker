import asyncio
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
_MAGIC_JPEG = b"\xff\xd8\xff"
_MAGIC_PNG = b"\x89PNG"


def _validate_image_magic(data: bytes) -> bool:
    """Validate image magic bytes. WebP requires full RIFF+WEBP signature check."""
    if data.startswith(_MAGIC_JPEG) or data.startswith(_MAGIC_PNG):
        return True
    # WebP: RIFF container with WEBP identifier at offset 8
    if data[:4] == b"RIFF" and len(data) >= 12 and data[8:12] == b"WEBP":
        return True
    return False


# In-memory rate limit trackers — separate counters per endpoint to prevent
# identify-machine requests from consuming analyze budget and vice versa.
_identify_rate_store: dict[str, tuple[str, int]] = {}
_analyze_rate_store: dict[str, tuple[str, int]] = {}
_rate_limit_lock = asyncio.Lock()


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


async def _check_rate_limit(
    store: dict[str, tuple[str, int]], user_id: str, limit: int
) -> None:
    """Check if user has exceeded the daily AI request limit.

    Tracks requests per calendar day (UTC). Resets automatically at midnight.
    Uses an async lock to prevent TOCTOU races under concurrency.
    Does NOT increment the counter — call _increment_rate_limit after success.
    """
    async with _rate_limit_lock:
        today = date.today().isoformat()

        # Evict entries from previous days to prevent unbounded growth.
        stale_keys = [uid for uid, (d, _) in store.items() if d != today]
        for key in stale_keys:
            del store[key]

        entry = store.get(user_id)

        if entry is not None:
            _, count = entry
            if count >= limit:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"Daily AI request limit of {limit} reached. Try again tomorrow.",
                )


async def _increment_rate_limit(
    store: dict[str, tuple[str, int]], user_id: str
) -> None:
    """Increment the rate limit counter after a successful AI call."""
    async with _rate_limit_lock:
        today = date.today().isoformat()
        entry = store.get(user_id)
        if entry is None:
            store[user_id] = (today, 1)
        else:
            stored_date, count = entry
            store[user_id] = (stored_date, count + 1)


@router.post("/identify-machine", response_model=MachineIdentificationResponse)
async def identify_machine(
    image: UploadFile,
    user_id: str = Depends(get_current_user),
    settings: Settings = Depends(get_settings),
) -> MachineIdentificationResponse:
    """Identify gym equipment from an uploaded photo using Claude AI.

    Accepts JPEG or PNG images up to 5 MB.  Results are cached per-user by
    SHA-256 image hash so identical images are never sent to the AI twice.
    Each authenticated user is limited to AI_RATE_LIMIT_PER_DAY requests per
    calendar day (default 10).
    """
    # --- Rate limiting (checked before reading bytes to fail fast) ---
    await _check_rate_limit(_identify_rate_store, user_id, settings.AI_RATE_LIMIT_PER_DAY)

    # --- File type validation ---
    content_type = (image.content_type or "").lower()
    if content_type not in _ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Unsupported image format. Accepted formats: JPEG, PNG, WebP.",
        )

    # --- Stream-read with early size abort to prevent DoS via large uploads ---
    chunks: list[bytes] = []
    total = 0
    while True:
        chunk = await image.read(65536)
        if not chunk:
            break
        total += len(chunk)
        if total > _MAX_IMAGE_BYTES:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    f"Image too large. Maximum allowed size is"
                    f" {_MAX_IMAGE_BYTES // (1024 * 1024)} MB."
                ),
            )
        chunks.append(chunk)
    image_bytes = b"".join(chunks)

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

    # --- Cache lookup (scoped to user to prevent cross-user leakage) ---
    image_hash = hashlib.sha256(image_bytes).hexdigest()
    cache_key = f"{user_id}:{image_hash}"
    cached = _image_cache.get(cache_key)
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

    # Increment rate limit only after successful AI call
    await _increment_rate_limit(_identify_rate_store, user_id)

    # Cache successful result
    _image_cache.set(cache_key, result)
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
    await _check_rate_limit(_analyze_rate_store, user_id, min(settings.AI_RATE_LIMIT_PER_DAY, 5))

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

    # Increment rate limit only after successful analysis
    await _increment_rate_limit(_analyze_rate_store, user_id)

    return AnalysisResponse(**result)

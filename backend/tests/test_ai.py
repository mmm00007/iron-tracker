import io
from datetime import date
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient

from app.models.schemas import MachineIdentificationResponse, TargetMuscles
from app.routers.ai import _analyze_rate_store, _identify_rate_store, _image_cache

FAKE_IDENTIFICATION = MachineIdentificationResponse(
    exercise_names=["Leg Press"],
    equipment_type="Plate-Loaded",
    manufacturer="Life Fitness",
    target_muscles=TargetMuscles(
        primary=["quadriceps", "glutes"],
        secondary=["hamstrings"],
    ),
    form_tips=[
        "Keep your back flat against the pad",
        "Do not lock your knees at the top",
        "Position feet shoulder-width apart",
    ],
    confidence="high",
)


@pytest.fixture(autouse=True)
def clear_rate_limit_and_cache() -> None:
    """Reset rate limit stores and image cache between tests."""
    _identify_rate_store.clear()
    _analyze_rate_store.clear()
    _image_cache.clear()
    yield
    _identify_rate_store.clear()
    _analyze_rate_store.clear()
    _image_cache.clear()


def _fake_jpeg_bytes() -> bytes:
    """Return minimal valid JPEG bytes for testing."""
    # A 1x1 white JPEG
    return (
        b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00"
        b"\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t"
        b"\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a"
        b"\x1f\x1e\x1d\x1a\x1c\x1c $.' \",#\x1c\x1c(7),\x01\x02\x03"
        b"\xff\xd9"
    )


def test_identify_machine_success(test_client: TestClient) -> None:
    """POST /api/ai/identify-machine should return identified machine data."""
    with patch(
        "app.routers.ai.AIService.identify_machine",
        new_callable=AsyncMock,
        return_value=FAKE_IDENTIFICATION,
    ):
        response = test_client.post(
            "/api/ai/identify-machine",
            files={"image": ("machine.jpg", io.BytesIO(_fake_jpeg_bytes()), "image/jpeg")},
        )

    assert response.status_code == 200
    data = response.json()
    assert "Leg Press" in data["exercise_names"]
    assert data["equipment_type"] == "Plate-Loaded"
    assert data["manufacturer"] == "Life Fitness"
    assert "quadriceps" in data["target_muscles"]["primary"]
    assert len(data["form_tips"]) == 3


def test_identify_machine_cached(test_client: TestClient) -> None:
    """Identical images should return cached result without calling AI service."""
    image_bytes = _fake_jpeg_bytes()
    call_count = 0

    async def mock_identify(self, image_bytes, content_type):  # noqa: N805
        nonlocal call_count
        call_count += 1
        return FAKE_IDENTIFICATION

    with patch("app.routers.ai.AIService.identify_machine", mock_identify):
        response1 = test_client.post(
            "/api/ai/identify-machine",
            files={"image": ("machine.jpg", io.BytesIO(image_bytes), "image/jpeg")},
        )
        response2 = test_client.post(
            "/api/ai/identify-machine",
            files={"image": ("machine.jpg", io.BytesIO(image_bytes), "image/jpeg")},
        )

    assert response1.status_code == 200
    assert response2.status_code == 200
    assert call_count == 1, "AI service should only be called once for the same image"


def test_identify_machine_unsupported_format(test_client: TestClient) -> None:
    """Unsupported image format should return 422."""
    response = test_client.post(
        "/api/ai/identify-machine",
        files={"image": ("doc.pdf", io.BytesIO(b"%PDF-1.4"), "application/pdf")},
    )
    assert response.status_code == 422


def test_identify_machine_rate_limit(test_client: TestClient) -> None:
    """Exceeding rate limit should return 429."""
    with patch(
        "app.routers.ai.AIService.identify_machine",
        new_callable=AsyncMock,
        return_value=FAKE_IDENTIFICATION,
    ):
        # Hit rate limit by setting count to the limit directly
        from tests.conftest import FAKE_USER_ID

        _identify_rate_store[FAKE_USER_ID] = (date.today().isoformat(), 10)  # Default limit

        response = test_client.post(
            "/api/ai/identify-machine",
            files={"image": ("machine.jpg", io.BytesIO(_fake_jpeg_bytes()), "image/jpeg")},
        )

    assert response.status_code == 429

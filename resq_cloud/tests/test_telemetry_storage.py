from unittest.mock import AsyncMock

import pytest

from app.routers.telemetry import receive
from app.schemas.telemetry import TelemetryData


@pytest.mark.asyncio
async def test_telemetry_is_stored_for_station_and_drone(monkeypatch) -> None:
    writes = []

    class FakeRedis:
        async def set(self, key, value) -> None:
            writes.append((key, value))

    monkeypatch.setattr(receive, "redis_client", FakeRedis())
    db = AsyncMock()

    response = await receive.receive_telemetry(
        TelemetryData(drone_id="drone-7", battery=79),
        db,
    )

    assert response["success"] is True
    assert {key for key, _ in writes} == {
        "telemetry:latest",
        "telemetry:drone:drone-7",
    }
    db.commit.assert_awaited_once()

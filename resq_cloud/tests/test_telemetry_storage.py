from unittest.mock import AsyncMock

import pytest

from app.routers.telemetry import latest
from app.routers.telemetry import receive
from app.routers.ai.models import discover_checkpoints
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


@pytest.mark.asyncio
async def test_simulated_telemetry_is_generated_by_backend() -> None:
    packet = await latest.get_simulated_telemetry()

    assert packet.drone_id == "SIM-UAV-01"
    assert packet.flight_mode == "SIMULATION"
    assert packet.status == "SIMULATED"
    assert 20 <= packet.battery <= 90
    assert packet.x is not None and packet.y is not None
    assert packet.timestamp is not None


def test_checkpoint_registry_discovers_nested_pth_files(tmp_path) -> None:
    checkpoint = tmp_path / "human" / "detection" / "v2.pth"
    checkpoint.parent.mkdir(parents=True)
    checkpoint.write_bytes(b"weights")
    (checkpoint.parent / "notes.txt").write_text("not a checkpoint")

    assert discover_checkpoints(tmp_path) == [
        {
            "category": "human",
            "name": "v2",
            "path": "human/detection/v2.pth",
            "size_bytes": 7,
        }
    ]

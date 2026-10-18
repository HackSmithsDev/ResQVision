from fastapi import APIRouter, HTTPException
from app.schemas.telemetry import TelemetryData
from app.utils.redis import redis_client
import json
import time
from datetime import datetime, timezone
import math

router = APIRouter()

@router.get("/simulated", response_model=TelemetryData)
async def get_simulated_telemetry():
    """Generate a moving demo track on the backend until flight hardware is connected."""
    now = time.time()
    phase = now / 12
    return TelemetryData(
        drone_id="SIM-UAV-01",
        callsign="SIM-01",
        battery=float(90 - int(now / 60) % 61),
        altitude=45 + math.sin(phase / 3) * 1.5,
        x=420 + 140 * math.cos(phase),
        y=280 + 140 * math.sin(phase),
        latitude=37.421998 + 0.001 * math.sin(phase),
        longitude=-122.084 + 0.001 * math.cos(phase),
        speed=11 + 2 * math.sin(phase / 2),
        status="SIMULATED",
        flight_mode="SIMULATION",
        signal=95 + 4 * math.sin(phase / 4),
        timestamp=datetime.fromtimestamp(now, timezone.utc),
    )

@router.get("/latest", response_model=TelemetryData)
async def get_latest_telemetry():
    """Return the latest telemetry synchronized by the ground station."""
    data = await redis_client.get("telemetry:latest")
    if not data:
        raise HTTPException(status_code=404, detail="No telemetry data available")
    return json.loads(data)


@router.get("/latest/{drone_id}", response_model=TelemetryData)
async def get_drone_specific_telemetry(drone_id: str):
    """Return the latest ground-station-synchronized telemetry for one drone."""
    data = await redis_client.get(f"telemetry:drone:{drone_id}")

    if not data:
        raise HTTPException(
            status_code=404, 
            detail=f"No telemetry data available for drone/session {drone_id}"
        )

    return json.loads(data)
from fastapi import APIRouter, HTTPException
from app.schemas.telemetry import TelemetryData
from app.utils.redis import redis_client
import json

router = APIRouter()


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
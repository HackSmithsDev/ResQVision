"""Intel schemas: video streams, atmospheric sensors, and alerts."""

from typing import Optional
from pydantic import Field
from resq_command.db.base import BaseClientModel


class StreamSource(BaseClientModel):
    """RTSP / WebRTC / USB video feed metadata."""

    source_id: str
    name: str
    uri: str
    resolution: str = "1080p"
    fps: int = 30
    latency_ms: int = 35
    is_online: bool = True
    feed_type: str = "RTSP"  # RTSP, WEBRTC, THERMAL, USB


class EnvironmentalReading(BaseClientModel):
    """Sensor pod telemetry (atmospheric, gases, water levels)."""

    sensor_id: str
    sensor_name: str
    metric_type: str  # CO, H2S, WATER_LEVEL, BAROMETER, WIND
    value: float
    unit: str
    threshold_critical: float
    threshold_warning: float
    status: str = "NOMINAL"  # NOMINAL, WARNING, CRITICAL


class NotificationAlert(BaseClientModel):
    """Tactical alert feed item dispatched across the EventBus."""

    alert_id: str
    severity: str  # CRITICAL, ALERT, INFO
    title: str
    description: str
    timestamp: str
    source_module: str = "SYSTEM"
    acknowledged: bool = False
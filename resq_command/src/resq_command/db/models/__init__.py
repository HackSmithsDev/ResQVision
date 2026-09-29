"""Consolidated export registry for all ResQVision domain data models."""

from resq_command.db.models.tactical import (
    DroneTelemetry,
    SquadMember,
    RescueSquad,
    GeofencePolygon,
)
from resq_command.db.models.intel import (
    StreamSource,
    EnvironmentalReading,
    NotificationAlert,
)
from resq_command.db.models.logistics import (
    InventoryItem,
    MeshNode,
)
from resq_command.db.models.command import (
    IncidentTicket,
    SOPStep,
    MissionProtocol,
    HardwareConfig,
)
from resq_command.db.models.jarvis import (
    JarvisIntent,
    JarvisVoiceState,
    JarvisActionAudit,
)

__all__ = [
    # Tactical
    "DroneTelemetry",
    "SquadMember",
    "RescueSquad",
    "GeofencePolygon",
    # Intel
    "StreamSource",
    "EnvironmentalReading",
    "NotificationAlert",
    # Logistics
    "InventoryItem",
    "MeshNode",
    # Command
    "IncidentTicket",
    "SOPStep",
    "MissionProtocol",
    "HardwareConfig",
    # Jarvis
    "JarvisIntent",
    "JarvisVoiceState",
    "JarvisActionAudit",
]
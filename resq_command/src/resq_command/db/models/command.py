"""Command schemas: SOS triage, SOP checklists, and hardware configuration."""

from typing import List, Optional
from pydantic import Field
from resq_command.db.base import BaseClientModel


class IncidentTicket(BaseClientModel):
    """Manual or automated SOS emergency dispatch ticket."""

    ticket_id: str
    title: str
    priority: str  # CRITICAL, URGENT, MINOR
    sector: str
    description: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    assigned_squad_id: Optional[str] = None
    status: str = "OPEN"  # OPEN, DISPATCHED, RESOLVED


class SOPStep(BaseClientModel):
    """Individual standard operating procedure item."""

    step_index: int
    title: str
    is_mandatory: bool = True
    is_completed: bool = False
    completed_by: Optional[str] = None


class MissionProtocol(BaseClientModel):
    """Operational phase checklist."""

    protocol_id: str
    phase_name: str
    steps: List[SOPStep] = Field(default_factory=list)


class HardwareConfig(BaseClientModel):
    """Saved local telemetry and video input configuration."""

    telemetry_udp_port: int = 14550
    video_device_name: Optional[str] = None
    video_stream_uri: Optional[str] = None
    simulation_mode: bool = False
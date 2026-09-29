"""Tactical schemas: drone telemetry, squad vitals, and operational zones."""

from typing import List, Optional, Tuple
from pydantic import Field
from resq_command.db.base import BaseClientModel


class DroneTelemetry(BaseClientModel):
    """Real-time flight telemetry for an airborne UAV."""

    drone_id: str
    callsign: str
    latitude: float
    longitude: float
    altitude_m: float = Field(default=0.0, ge=0.0)
    ground_speed_mps: float = Field(default=0.0, ge=0.0)
    heading_deg: float = Field(default=0.0, ge=0.0, le=360.0)
    battery_pct: int = Field(default=100, ge=0, le=100)
    flight_mode: str = "LOITER"  # MANUAL, AUTO, RTL, GUIDED, LAND
    status: str = "AIRBORNE"     # AIRBORNE, SEARCHING, DOCKED, CRITICAL
    canvas_x: Optional[float] = None
    canvas_y: Optional[float] = None


class SquadMember(BaseClientModel):
    """Individual responder vitals and field tracking."""

    member_id: str
    name: str
    role: str
    heart_rate_bpm: int = Field(default=75, ge=30, le=220)
    body_temp_c: float = Field(default=37.0)
    battery_radio_pct: int = Field(default=100, ge=0, le=100)
    status: str = "NOMINAL"  # NOMINAL, ELEVATED, DISTRESS


class RescueSquad(BaseClientModel):
    """Field squad roster and assigned operational sector."""

    squad_id: str
    callsign: str
    assigned_sector: str
    mission_role: str
    members: List[SquadMember] = Field(default_factory=list)
    lead_contact: str = ""
    status: str = "ACTIVE ASSIST"


class GeofencePolygon(BaseClientModel):
    """Restricted or search perimeter boundary coordinates."""

    zone_id: str
    name: str
    zone_type: str = "HAZARD"  # HAZARD, SEARCH_GRID, EXCLUSION
    coordinates: List[Tuple[float, float]] = Field(default_factory=list)
    color_hex: str = "#FF334B"
    is_active: bool = True
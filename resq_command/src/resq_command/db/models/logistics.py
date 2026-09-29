"""Logistics schemas: depot inventory, LiPo chargers, and mesh nodes."""

from pydantic import Field
from resq_command.db.base import BaseClientModel


class InventoryItem(BaseClientModel):
    """Stock item inside the logistics depot."""

    item_code: str
    name: str
    category: str  # BATTERY, MEDICAL, COMMS, HAZMAT, RESCUE
    depot_bin: str
    quantity_available: int = Field(default=0, ge=0)
    quantity_reserved: int = Field(default=0, ge=0)
    charge_level_pct: int = Field(default=100, ge=0, le=100)
    condition: str = "READY"  # READY, CHARGING, DAMAGED, RESTOCK_DUE


class MeshNode(BaseClientModel):
    """LoRa RF repeater and node link quality."""

    node_id: str
    callsign: str
    role: str = "ACTIVE ROUTER"  # ROOT, ACTIVE ROUTER, ENDPOINT
    rssi_dbm: float = -70.0
    snr_db: float = 8.0
    packet_loss_pct: float = Field(default=0.0, ge=0.0, le=100.0)
    battery_pct: int = Field(default=100, ge=0, le=100)
    is_online: bool = True
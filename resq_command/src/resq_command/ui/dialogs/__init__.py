"""Tactical modals and action confirmation dialogs."""

from resq_command.ui.dialogs.emergency_kill_dialog import EmergencyKillDialog
from resq_command.ui.dialogs.payload_drop_dialog import PayloadDropDialog
from resq_command.ui.dialogs.incident_dispatch_dialog import IncidentDispatchDialog
from resq_command.ui.dialogs.port_connect_dialog import PortConnectDialog

__all__ = [
    "EmergencyKillDialog",
    "PayloadDropDialog",
    "IncidentDispatchDialog",
    "PortConnectDialog",
]
"""
Sub-page 09: Incident Triage & Emergency SOS Dispatch.
Uses global QSS tokens, dynamic Qt properties, and IncidentDispatchDialog.
"""

from datetime import datetime
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame,
    QPushButton, QScrollArea
)
from resq_command.db.models import IncidentTicket
from resq_command.ui.dialogs.incident_dispatch_dialog import IncidentDispatchDialog
from resq_command.ui.widgets.status_badge import StatusBadge


class IncidentRisksPage(QWidget):
    """SOS Triage Priority Queue & Incident Management."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        header_title = QLabel("INCIDENT TRIAGE & EMERGENCY DISPATCH")
        header_title.setProperty("variant", "header")
        header.addWidget(header_title)
        header.addStretch()

        sos_btn = QPushButton("+ MANUAL INCIDENT DISPATCH")
        sos_btn.setProperty("variant", "primary")
        sos_btn.clicked.connect(self._open_dispatch_dialog)
        header.addWidget(sos_btn)
        root.addLayout(header)

        # Scroll Area for active incidents
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)

        self.container = QWidget()
        self.scroll_lay = QVBoxLayout(self.container)
        self.scroll_lay.setSpacing(10)

        initial_incidents = [
            IncidentTicket(
                ticket_id="INC-001",
                title="COLLAPSED RESIDENTIAL STRUCTURE",
                priority="CRITICAL",
                sector="SECTOR A-04",
                description="3 victims detected beneath rubble. Thermal hotspot confirmed."
            ),
            IncidentTicket(
                ticket_id="INC-002",
                title="ROADWAY FLOOD INUNDATION",
                priority="URGENT",
                sector="RIVER SECTOR B-12",
                description="Evacuation route submerged under 1.2m of swift water."
            ),
            IncidentTicket(
                ticket_id="INC-003",
                title="FIRST AID & REHYDRATION POST",
                priority="MINOR",
                sector="BASE CAMP ALPHA",
                description="Walking wounded shelter established at primary school."
            ),
        ]

        for incident in initial_incidents:
            self._add_incident_ticket(incident)

        self.scroll_lay.addStretch()
        scroll.setWidget(self.container)
        root.addWidget(scroll)

        if self.event_bus:
            self.event_bus.alert_triggered.connect(self._on_external_alert)

    def _add_incident_ticket(self, ticket: IncidentTicket):
        variant_map = {
            "CRITICAL": ("card-critical", "CRITICAL"),
            "URGENT": ("card-warning", "WARNING"),
            "MINOR": ("card-nominal", "NOMINAL"),
        }
        card_variant, badge_level = variant_map.get(ticket.priority.upper(), ("card", "NOMINAL"))

        card = QFrame()
        card.setProperty("variant", card_variant)
        c_lay = QVBoxLayout(card)
        c_lay.setSpacing(6)

        top = QHBoxLayout()
        badge = StatusBadge(ticket.priority, badge_level)
        top.addWidget(badge)

        title_lbl = QLabel(f"<b>{ticket.title}</b>")
        top.addWidget(title_lbl)
        top.addStretch()

        ts_str = ticket.created_at.strftime("%H:%M:%S")
        meta_lbl = QLabel(f"{ts_str} | <b>{ticket.sector}</b>")
        meta_lbl.setProperty("variant", "meta")
        top.addWidget(meta_lbl)
        c_lay.addLayout(top)

        desc_lbl = QLabel(ticket.description)
        c_lay.addWidget(desc_lbl)

        btn_row = QHBoxLayout()
        btn_row.addStretch()
        assign_btn = QPushButton("ASSIGN TEAM")
        assign_btn.clicked.connect(lambda: assign_btn.setText("TEAM DISPATCHED"))
        btn_row.addWidget(assign_btn)
        c_lay.addLayout(btn_row)

        self.scroll_lay.insertWidget(self.scroll_lay.count() - 1, card)

    def _open_dispatch_dialog(self):
        dialog = IncidentDispatchDialog(self)
        if dialog.exec():
            data = dialog.get_data()
            priority_clean = "CRITICAL" if "CRITICAL" in data["priority"] else ("URGENT" if "URGENT" in data["priority"] else "MINOR")
            ticket = IncidentTicket(
                ticket_id=f"INC-{datetime.now().strftime('%M%S')}",
                title=data["title"] or "MANUAL SOS TICKET",
                priority=priority_clean,
                sector="SECTOR ACTIVE",
                description=data["description"] or "Field operator manual dispatch request."
            )
            self._add_incident_ticket(ticket)

    def _on_external_alert(self, alert_data: dict):
        if alert_data.get("severity") in ["CRITICAL", "ALERT"]:
            ticket = IncidentTicket(
                ticket_id=f"ALERT-{datetime.now().strftime('%S')}",
                title=alert_data.get("title", "SYSTEM ALERT"),
                priority="CRITICAL" if alert_data.get("severity") == "CRITICAL" else "URGENT",
                sector="SECTOR TELEMETRY",
                description=alert_data.get("desc", "Autonomous alert triggered by telemetry engine.")
            )
            self._add_incident_ticket(ticket)
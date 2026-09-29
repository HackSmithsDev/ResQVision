"""
Sub-page 02: Airborne Drone Fleet Telemetry & Payload Station.
Styled via cards.qss, buttons.qss, and the StatusBadge widget.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame, QGridLayout, QPushButton
from resq_command.ui.widgets.status_badge import StatusBadge


class DronesPage(QWidget):
    """Active UAV Fleet Cockpit & Emergency RTL Actions."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(16)

        # Header
        header = QHBoxLayout()
        header_title = QLabel("ACTIVE UAV FLEET // SQUADRON ALPHA")
        header_title.setProperty("variant", "header")
        header.addWidget(header_title)
        header.addStretch()
        root.addLayout(header)

        # Grid of Drone Telemetry Cards
        grid = QGridLayout()
        grid.setSpacing(14)

        drones_data = [
            ("UAV-01 RECON", "AIRBORNE", "87%", "45m", "12.4 m/s", "NOMINAL", "card"),
            ("UAV-02 THERMAL", "SEARCHING", "64%", "38m", "8.2 m/s", "NOMINAL", "card"),
            ("UAV-03 CARGO", "RETURNING (RTL)", "18%", "15m", "6.1 m/s", "WARNING", "card-warning"),
            ("UAV-04 RELAY", "OFFLINE (DOCK)", "100%", "0m", "0.0 m/s", "MUTED", "card"),
        ]

        for i, (callsign, status, bat, alt, spd, badge_lvl, card_var) in enumerate(drones_data):
            card = QFrame()
            card.setProperty("variant", card_var)
            c_lay = QVBoxLayout(card)
            c_lay.setSpacing(10)

            # Header Row
            top_row = QHBoxLayout()
            callsign_lbl = QLabel(f"<b>{callsign}</b>")
            callsign_lbl.setProperty("variant", "title")
            top_row.addWidget(callsign_lbl)
            top_row.addStretch()

            pill = StatusBadge(status, badge_lvl)
            top_row.addWidget(pill)
            c_lay.addLayout(top_row)

            # Telemetry Metrics
            stats = QLabel(
                f"<span style='color:palette(mid);'>BATTERY:</span> <b>{bat}</b> &nbsp;|&nbsp; "
                f"<span style='color:palette(mid);'>ALT:</span> <b>{alt}</b> &nbsp;|&nbsp; "
                f"<span style='color:palette(mid);'>SPEED:</span> <b>{spd}</b>"
            )
            c_lay.addWidget(stats)

            # Return-to-Launch Button
            btn = QPushButton("RTL (RETURN HOME)")
            btn.clicked.connect(lambda _, cs=callsign: self._trigger_rtl(cs))
            c_lay.addWidget(btn)

            row, col = divmod(i, 2)
            grid.addWidget(card, row, col)

        root.addLayout(grid)
        root.addStretch()

    def _trigger_rtl(self, callsign: str):
        if self.event_bus:
            self.event_bus.jarvis_action_dispatched.emit("rtl_drone", {"callsign": callsign})
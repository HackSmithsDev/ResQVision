"""
Sub-page 08: LoRa / RF Field Mesh Link Topology & Signal Quality.
Styled via global cards.qss, buttons.qss, and the SignalMeter & StatusBadge widgets.
"""

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame,
    QGridLayout, QPushButton, QProgressBar
)
from resq_command.ui.widgets.status_badge import StatusBadge
from resq_command.ui.widgets.signal_meter import SignalMeter


class CommsMeshPage(QWidget):
    """Field Comms Topology: LoRa RF Mesh (915 MHz) Nodes & Signal Meters."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        header_title = QLabel("FIELD COMMS TOPOLOGY // LORA RF MESH (915 MHz)")
        header_title.setProperty("variant", "header")
        header.addWidget(header_title)
        header.addStretch()

        ping_btn = QPushButton("PING ALL NODES")
        ping_btn.setProperty("variant", "primary")
        header.addWidget(ping_btn)
        root.addLayout(header)

        grid = QGridLayout()
        grid.setSpacing(14)

        nodes = [
            ("BASE COMMAND (STATION)", "ONLINE (ROOT)", "-42 dBm", "11.2 dB", 5, 98, "NOMINAL", "card"),
            ("REPEATER NODE-01 (HILLTOP)", "ACTIVE ROUTER", "-68 dBm", "8.5 dB", 4, 84, "NOMINAL", "card"),
            ("REPEATER NODE-02 (VALLEY)", "ACTIVE ROUTER", "-88 dBm", "4.1 dB", 2, 42, "WARNING", "card-warning"),
            ("SQUAD RELAY ALPHA", "MOBILE ENDPOINT", "-74 dBm", "7.0 dB", 4, 76, "NOMINAL", "card"),
        ]

        for i, (name, role, rssi, snr, bars, signal_pct, status_lvl, card_var) in enumerate(nodes):
            card = QFrame()
            card.setProperty("variant", card_var)
            c_lay = QVBoxLayout(card)
            c_lay.setSpacing(8)

            top = QHBoxLayout()
            badge = StatusBadge(role, status_lvl)
            top.addWidget(badge)

            node_name = QLabel(f"<b>{name}</b>")
            top.addWidget(node_name)
            top.addStretch()

            meter = SignalMeter(bars, self)
            top.addWidget(meter)
            c_lay.addLayout(top)

            metrics = QLabel(
                f"<span style='color:palette(mid);'>RSSI:</span> <b>{rssi}</b> &nbsp;|&nbsp; "
                f"<span style='color:palette(mid);'>SNR:</span> <b>{snr}</b>"
            )
            c_lay.addWidget(metrics)

            pbar = QProgressBar()
            pbar.setValue(signal_pct)
            pbar.setTextVisible(False)
            pbar.setFixedHeight(6)
            c_lay.addWidget(pbar)

            row, col = divmod(i, 2)
            grid.addWidget(card, row, col)

        root.addLayout(grid)
        root.addStretch()

        if self.event_bus:
            self.event_bus.mesh_status_updated.connect(self._on_mesh_update)

    def _on_mesh_update(self, data: dict):
        pass
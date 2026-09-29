from PySide6.QtWidgets import QFrame, QVBoxLayout, QLabel
from resq_command.style.palette import TacticalPalette
from resq_command.ui.widgets.stat_chip import StatChip
from resq_command.ui.widgets.circular_gauge import CircularGauge

class QuickTelemetryBar(QFrame):
    """Right-anchored telemetry strip for active aircraft vitals."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedWidth(160)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {TacticalPalette.BG_PANEL};
                border-left: 1px solid {TacticalPalette.SURFACE_BORDER};
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 16, 12, 16)
        layout.setSpacing(12)

        header = QLabel("<b>RECON-01</b>")
        header.setStyleSheet(f"color: {TacticalPalette.INDIGO_PRIMARY}; font-size: 13px;")
        layout.addWidget(header)

        self.gauge = CircularGauge("BATTERY", 88, self)
        layout.addWidget(self.gauge)

        self.alt_chip = StatChip("ALT", "45.2 m", "NOMINAL", self)
        self.speed_chip = StatChip("SPD", "12.4 m/s", "NOMINAL", self)
        self.sat_chip = StatChip("GNSS", "16 SATS", "NOMINAL", self)

        layout.addWidget(self.alt_chip)
        layout.addWidget(self.speed_chip)
        layout.addWidget(self.sat_chip)

        layout.addStretch()

    def update_telemetry(self, data: dict):
        if "battery" in data:
            self.gauge.set_value(int(data["battery"]))
        if "altitude" in data:
            self.alt_chip.set_value(f"{data['altitude']:.1f} m")
        if "ground_speed" in data:
            self.speed_chip.set_value(f"{data['ground_speed']:.1f} m/s")
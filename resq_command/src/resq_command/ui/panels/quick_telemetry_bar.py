from PySide6.QtWidgets import QFrame, QVBoxLayout, QLabel
from resq_command.style.palette import TacticalPalette

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

        header = QLabel("<b>LIVE TELEMETRY</b>")
        header.setStyleSheet(f"color: {TacticalPalette.INDIGO_PRIMARY}; font-size: 13px;")
        layout.addWidget(header)

        self.battery = QLabel("Battery: —")
        self.altitude = QLabel("Altitude: —")
        self.speed = QLabel("Ground speed: —")
        self.status = QLabel("No telemetry received")
        self.status.setWordWrap(True)
        for label in (self.battery, self.altitude, self.speed, self.status):
            layout.addWidget(label)

        layout.addStretch()

    def update_telemetry(self, data: dict):
        self.status.setText("Receiving telemetry")
        if data.get("battery") is not None:
            self.battery.setText(f"Battery: {data['battery']}%")
        if data.get("altitude") is not None:
            self.altitude.setText(f"Altitude: {data['altitude']} m")
        speed = data.get("ground_speed", data.get("speed"))
        if speed is not None:
            self.speed.setText(f"Ground speed: {speed} m/s")
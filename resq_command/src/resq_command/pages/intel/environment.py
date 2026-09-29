"""
Sub-page 05: Gas Sensors, River Gauges & Atmospheric Monitoring.
Leverages global card and badge stylesheet tokens with real-time EventBus updates.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame, QGridLayout
from resq_command.ui.widgets.status_badge import StatusBadge
from resq_command.db.models import EnvironmentalReading


class EnvironmentPage(QWidget):
    """Environmental Telemetry & Toxic Gas / Flood Monitoring."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.sensor_cards = {}

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        title = QLabel("ENVIRONMENTAL TELEMETRY & HAZARD MONITORING")
        title.setProperty("variant", "header")
        header.addWidget(title)
        header.addStretch()
        root.addLayout(header)

        self.grid = QGridLayout()
        self.grid.setSpacing(14)

        sensors = [
            ("CARBON MONOXIDE (CO)", "12 PPM", "SAFE (< 25 PPM)", "NOMINAL", "card"),
            ("TOXIC GAS (H2S)", "4.8 PPM", "ELEVATED CONCENTRATION", "WARNING", "card-warning"),
            ("RIVER WATER CREST", "4.2 METERS", "FLOOD THRESHOLD 5.0m", "WARNING", "card-warning"),
            ("AMBIENT BAROMETER", "1013.2 hPa", "STABLE SYSTEM", "NOMINAL", "card"),
            ("SECTOR WIND SPEED", "18 KNOTS", "GUSTS 24 KTS", "MUTED", "card"),
            ("SURFACE TEMPERATURE", "34.2 °C", "DRY GROUND", "MUTED", "card"),
        ]

        for i, (title_str, val, note, status_level, card_var) in enumerate(sensors):
            card = QFrame()
            card.setProperty("variant", card_var)
            c_lay = QVBoxLayout(card)
            c_lay.setSpacing(6)

            title_lbl = QLabel(title_str)
            title_lbl.setProperty("variant", "meta")
            c_lay.addWidget(title_lbl)

            val_lbl = QLabel(f"<b>{val}</b>")
            val_lbl.setProperty("variant", "metric-large")
            c_lay.addWidget(val_lbl)

            badge = StatusBadge(note, status_level)
            c_lay.addWidget(badge)

            row, col = divmod(i, 3)
            self.grid.addWidget(card, row, col)
            self.sensor_cards[title_str] = (val_lbl, badge)

        root.addLayout(self.grid)
        root.addStretch()

        if self.event_bus:
            self.event_bus.sensor_reading_updated.connect(self._on_sensor_update)

    def _on_sensor_update(self, data: dict):
        sensor_name = data.get("sensor_name")
        if sensor_name in self.sensor_cards:
            val_lbl, badge = self.sensor_cards[sensor_name]
            val_lbl.setText(f"<b>{data.get('value')} {data.get('unit', '')}</b>")
            badge.set_status(data.get("status", "NOMINAL"), data.get("status", "NOMINAL"))
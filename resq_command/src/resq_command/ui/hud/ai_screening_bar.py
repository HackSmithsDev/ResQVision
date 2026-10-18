# src/resq_command/ui/hud/ai_screening_bar.py
from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel
from resq_command.ui.hud.siri_orb_widget import SiriOrbWidget
from resq_command.style.palette import TacticalPalette

class AIScreeningBar(QFrame):
    """Institutional Top HUD Bar with Jarvis Orb & System Level Tickers."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.setFixedHeight(64)
        
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {TacticalPalette.BG_PANEL};
                border-bottom: 1px solid {TacticalPalette.SURFACE_BORDER};
            }}
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(20, 0, 24, 0)
        layout.setSpacing(16)

        # 1. Government / Authority Branding
        brand_label = QLabel("<b>RESQVISION</b> <span style='color:{TacticalPalette.INDIGO_ACCENT}'>//</span> COMMAND")
        brand_label.setStyleSheet(f"""
            color: {TacticalPalette.INDIGO_PRIMARY};
            font-size: 15px;
            font-weight: 800;
            letter-spacing: 1.5px;
        """)
        layout.addWidget(brand_label)

        layout.addSpacing(16)

        # 2. Siri/Jarvis Voice Orb & State Readout
        self.orb = SiriOrbWidget(self)
        layout.addWidget(self.orb)

        self.status_readout = QLabel("Awaiting live telemetry")
        self.status_readout.setStyleSheet(f"""
            color: {TacticalPalette.TEXT_SECONDARY};
            font-weight: 600;
            font-size: 12px;
            letter-spacing: 0.5px;
        """)
        layout.addWidget(self.status_readout)

        layout.addStretch()

        self.level_badge = QLabel("NO LIVE DATA")
        self.level_badge.setStyleSheet(f"""
            background-color: {TacticalPalette.LEVEL_GREEN_BG};
            color: {TacticalPalette.LEVEL_GREEN};
            border: 1px solid #BBF7D0;
            padding: 5px 12px;
            border-radius: 14px;
            font-weight: 800;
            font-size: 11px;
        """)
        layout.addWidget(self.level_badge)

        if self.event_bus:
            self.event_bus.telemetry_updated.connect(self.update_telemetry)

    def update_telemetry(self, data: dict) -> None:
        identity = data.get("callsign") or data.get("drone_id") or "TRACK"
        details = [str(data.get("flight_mode") or data.get("status") or "LIVE")]
        if data.get("altitude") is not None:
            details.append(f"ALT {data['altitude']:.1f} m")
        if data.get("battery") is not None:
            details.append(f"BAT {data['battery']:.0f}%")
        self.status_readout.setText(f"{identity}  |  {'  |  '.join(details)}")

        battery = data.get("battery")
        if isinstance(battery, (int, float)):
            level_color, level_background = (
                (TacticalPalette.LEVEL_RED, TacticalPalette.LEVEL_RED_BG)
                if battery <= 20
                else (TacticalPalette.LEVEL_GREEN, TacticalPalette.LEVEL_GREEN_BG)
            )
            label = f"BATTERY {battery:.0f}%"
        else:
            level_color = TacticalPalette.TEXT_SECONDARY
            level_background = TacticalPalette.BG_PANEL
            label = str(data.get("flight_mode") or data.get("status") or "LIVE DATA").upper()
        self.level_badge.setText(label)
        self.level_badge.setStyleSheet(
            f"background-color: {level_background}; color: {level_color}; "
            f"border: 1px solid {level_color}; padding: 5px 12px; "
            "border-radius: 14px; font-weight: 800; font-size: 11px;"
        )

# src/resq_command/ui/hud/ai_screening_bar.py
from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel, QPushButton
from PySide6.QtCore import Qt
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

        self.status_readout = QLabel("JARVIS ONLINE // STANDING BY")
        self.status_readout.setStyleSheet(f"""
            color: {TacticalPalette.TEXT_SECONDARY};
            font-weight: 600;
            font-size: 12px;
            letter-spacing: 0.5px;
        """)
        layout.addWidget(self.status_readout)

        layout.addStretch()

        # 3. Quick Trigger (Voice Simulation Button)
        self.test_action_btn = QPushButton("EXECUTE: DEPLOY RECON")
        self.test_action_btn.setStyleSheet(f"""
            QPushButton {{
                background-color: {TacticalPalette.VIOLET_LIGHT};
                border: 1px solid {TacticalPalette.VIOLET_GLOW};
                color: {TacticalPalette.INDIGO_PRIMARY};
                padding: 7px 16px;
                border-radius: 6px;
                font-weight: 700;
                font-size: 11px;
            }}
            QPushButton:hover {{
                background-color: {TacticalPalette.INDIGO_ACCENT};
                color: #FFFFFF;
            }}
        """)
        self.test_action_btn.clicked.connect(self._on_simulated_command)
        layout.addWidget(self.test_action_btn)

        # 4. Universal Level Badge (Green / Nominal)
        self.level_badge = QLabel("SYSTEM: NOMINAL")
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

    def _on_simulated_command(self):
        self.orb.set_state("EXECUTING")
        self.status_readout.setText("JARVIS // ROUTING RECON-01 TO SECTOR BRAVO")
        self.status_readout.setStyleSheet(f"color: {TacticalPalette.LEVEL_YELLOW}; font-weight: bold;")
        self.event_bus.jarvis_action_dispatched.emit("deploy_drone", {"drone_id": "RECON-01", "sector": "BRAVO"})
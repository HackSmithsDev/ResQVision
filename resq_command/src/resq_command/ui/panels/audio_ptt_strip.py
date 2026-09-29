from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel, QPushButton, QComboBox
from resq_command.style.palette import TacticalPalette

class AudioPTTStrip(QFrame):
    """Bottom push-to-talk strip and RF channel switcher."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.setFixedHeight(44)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {TacticalPalette.BG_PANEL};
                border-top: 1px solid {TacticalPalette.SURFACE_BORDER};
            }}
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 4, 16, 4)
        layout.setSpacing(12)

        layout.addWidget(QLabel("<b>FIELD RADIO CHANNEL:</b>"))
        self.chan_combo = QComboBox()
        self.chan_combo.addItems(["CH 01 // TACTICAL DISPATCH (462.562 MHz)", "CH 02 // SQUAD SQUAD SEARCH (462.612 MHz)", "CH 03 // AIR SUPPORT RELAY"])
        layout.addWidget(self.chan_combo)

        layout.addStretch()

        self.ptt_btn = QPushButton("HOLD TO TALK [SPACE]")
        self.ptt_btn.setStyleSheet(f"""
            QPushButton {{
                background-color: {TacticalPalette.BG_CARD};
                border: 1px solid {TacticalPalette.SURFACE_BORDER};
                color: {TacticalPalette.TEXT_PRIMARY};
                font-weight: 800;
                padding: 6px 18px;
                border-radius: 4px;
            }}
            QPushButton:pressed {{
                background-color: {TacticalPalette.LEVEL_RED};
                color: #FFFFFF;
            }}
        """)
        layout.addWidget(self.ptt_btn)
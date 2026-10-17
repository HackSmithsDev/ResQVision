from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel
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

        layout.addStretch()
        layout.addWidget(QLabel("Radio PTT hardware is not configured"))
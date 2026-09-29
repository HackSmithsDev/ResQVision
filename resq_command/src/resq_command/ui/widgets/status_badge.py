from PySide6.QtWidgets import QLabel
from resq_command.style.palette import TacticalPalette

class StatusBadge(QLabel):
    """Pill tag indicating operational status (ARMED, RTL, OFFLINE, CRITICAL)."""

    def __init__(self, text: str = "ONLINE", status: str = "NOMINAL", parent=None):
        super().__init__(text, parent)
        self.set_status(text, status)

    def set_status(self, text: str, status: str):
        self.setText(text.upper())
        status_map = {
            "NOMINAL": (TacticalPalette.LEVEL_GREEN, TacticalPalette.LEVEL_GREEN_BG),
            "WARNING": (TacticalPalette.LEVEL_YELLOW, TacticalPalette.LEVEL_YELLOW_BG),
            "CRITICAL": (TacticalPalette.LEVEL_RED, TacticalPalette.LEVEL_RED_BG),
            "MUTED": (TacticalPalette.TEXT_MUTED, TacticalPalette.BG_CARD),
        }
        fg, bg = status_map.get(status.upper(), (TacticalPalette.TEXT_PRIMARY, TacticalPalette.BG_CARD))
        self.setStyleSheet(f"""
            QLabel {{
                background-color: {bg};
                color: {fg};
                border: 1px solid {TacticalPalette.SURFACE_BORDER};
                border-radius: 4px;
                padding: 3px 8px;
                font-size: 10px;
                font-weight: 800;
            }}
        """)
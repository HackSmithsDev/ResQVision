from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel
from resq_command.style.palette import TacticalPalette

class StatChip(QFrame):
    """High-density key-value metric badge with dynamic color states."""

    def __init__(self, label: str, value: str, level: str = "NOMINAL", parent=None):
        super().__init__(parent)
        self.setProperty("variant", "chip")

        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 4, 8, 4)
        layout.setSpacing(6)

        self.lbl_title = QLabel(f"{label}:")
        self.lbl_title.setStyleSheet(f"color: {TacticalPalette.TEXT_MUTED}; font-size: 10px; font-weight: 700;")
        layout.addWidget(self.lbl_title)

        self.lbl_val = QLabel(value)
        self.lbl_val.setStyleSheet(f"color: {TacticalPalette.TEXT_PRIMARY}; font-size: 11px; font-weight: 800;")
        layout.addWidget(self.lbl_val)

        self.set_level(level)

    def set_value(self, val: str):
        self.lbl_val.setText(val)

    def set_level(self, level: str):
        color_map = {
            "NOMINAL": (TacticalPalette.LEVEL_GREEN, TacticalPalette.LEVEL_GREEN_BG),
            "WARNING": (TacticalPalette.LEVEL_YELLOW, TacticalPalette.LEVEL_YELLOW_BG),
            "CRITICAL": (TacticalPalette.LEVEL_RED, TacticalPalette.LEVEL_RED_BG),
        }
        text_color, bg_color = color_map.get(level.upper(), (TacticalPalette.TEXT_PRIMARY, TacticalPalette.BG_CARD))
        self.setStyleSheet(f"""
            QFrame[variant="chip"] {{
                background-color: {bg_color};
                border: 1px solid {TacticalPalette.SURFACE_BORDER};
                border-radius: 4px;
            }}
        """)
        self.lbl_val.setStyleSheet(f"color: {text_color}; font-size: 11px; font-weight: 800;")
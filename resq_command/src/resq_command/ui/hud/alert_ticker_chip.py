from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel
from PySide6.QtCore import Signal
from resq_command.style.palette import TacticalPalette

class AlertTickerChip(QFrame):
    """Clickable alert count ticker in the top bar."""
    clicked = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.alert_count = 0
        self.setCursor(True)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(10, 4, 10, 4)

        self.label = QLabel("0 ALERTS // NOMINAL")
        self.label.setStyleSheet(f"""
            color: {TacticalPalette.LEVEL_GREEN};
            font-size: 11px;
            font-weight: 800;
        """)
        layout.addWidget(self.label)
        self._update_style("NOMINAL")

    def mousePressEvent(self, event):
        self.clicked.emit()

    def set_count(self, count: int, severity: str = "NOMINAL"):
        self.alert_count = count
        if count == 0:
            self.label.setText("0 ALERTS // NOMINAL")
            self._update_style("NOMINAL")
        elif severity == "CRITICAL":
            self.label.setText(f"{count} ALERTS // CRITICAL")
            self._update_style("CRITICAL")
        else:
            self.label.setText(f"{count} ALERTS // ELEVATED")
            self._update_style("WARNING")

    def _update_style(self, level: str):
        colors = {
            "NOMINAL": (TacticalPalette.LEVEL_GREEN, TacticalPalette.LEVEL_GREEN_BG),
            "WARNING": (TacticalPalette.LEVEL_YELLOW, TacticalPalette.LEVEL_YELLOW_BG),
            "CRITICAL": (TacticalPalette.LEVEL_RED, TacticalPalette.LEVEL_RED_BG),
        }
        fg, bg = colors.get(level, (TacticalPalette.TEXT_PRIMARY, TacticalPalette.BG_CARD))
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {bg};
                border: 1px solid {TacticalPalette.SURFACE_BORDER};
                border-radius: 12px;
            }}
            QFrame:hover {{
                border-color: {TacticalPalette.INDIGO_ACCENT};
            }}
        """)
        self.label.setStyleSheet(f"color: {fg}; font-size: 11px; font-weight: 800;")
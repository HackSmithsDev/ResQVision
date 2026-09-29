from PySide6.QtWidgets import QWidget
from PySide6.QtCore import Qt, QRect
from PySide6.QtGui import QPainter, QColor
from resq_command.style.palette import TacticalPalette

class SignalMeter(QWidget):
    """5-bar signal strength meter for LoRa & UAV radio links."""

    def __init__(self, strength_bars: int = 4, parent=None):
        super().__init__(parent)
        self.strength = max(0, min(5, strength_bars))
        self.setFixedSize(28, 20)

    def set_strength(self, bars: int):
        self.strength = max(0, min(5, bars))
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        bar_width = 3
        gap = 2
        for i in range(5):
            h = int(4 + i * 3.5)
            x = i * (bar_width + gap)
            y = self.height() - h

            if i < self.strength:
                color = TacticalPalette.LEVEL_GREEN if self.strength > 2 else TacticalPalette.LEVEL_YELLOW
            else:
                color = TacticalPalette.SURFACE_BORDER

            painter.fillRect(QRect(x, y, bar_width, h), QColor(color))
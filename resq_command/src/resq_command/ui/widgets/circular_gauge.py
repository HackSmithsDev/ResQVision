import math
from PySide6.QtWidgets import QWidget
from PySide6.QtCore import Qt, QRectF
from PySide6.QtGui import QPainter, QColor, QPen
from resq_command.style.palette import TacticalPalette

class CircularGauge(QWidget):
    """QPainter circular radial percentage meter."""

    def __init__(self, title: str = "BATTERY", value: int = 100, parent=None):
        super().__init__(parent)
        self.title = title
        self.value = value
        self.setFixedSize(90, 90)

    def set_value(self, val: int):
        self.value = max(0, min(100, val))
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        rect = QRectF(8, 8, self.width() - 16, self.height() - 16)
        
        # Background Track
        track_pen = QPen(QColor(TacticalPalette.SURFACE_BORDER_LIGHT), 6, Qt.SolidLine, Qt.RoundCap)
        painter.setPen(track_pen)
        painter.drawArc(rect, -45 * 16, 270 * 16)

        # Dynamic Value Arc
        span_angle = int(270 * (self.value / 100.0) * 16)
        color = TacticalPalette.LEVEL_GREEN if self.value > 25 else TacticalPalette.LEVEL_RED
        arc_pen = QPen(QColor(color), 6, Qt.SolidLine, Qt.RoundCap)
        painter.setPen(arc_pen)
        painter.drawArc(rect, (225 - int(270 * (self.value / 100.0))) * 16, span_angle)

        # Text readout
        painter.setPen(QColor(TacticalPalette.TEXT_PRIMARY))
        painter.drawText(QRectF(0, 26, self.width(), 20), Qt.AlignCenter, f"{self.value}%")
        painter.setPen(QColor(TacticalPalette.TEXT_MUTED))
        painter.drawText(QRectF(0, 48, self.width(), 16), Qt.AlignCenter, self.title)
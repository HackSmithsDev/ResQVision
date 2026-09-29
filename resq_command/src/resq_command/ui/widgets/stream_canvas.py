from PySide6.QtWidgets import QWidget
from PySide6.QtCore import Qt, QRect
from PySide6.QtGui import QPainter, QImage, QColor
from resq_command.style.palette import TacticalPalette

class StreamCanvas(QWidget):
    """Fast viewport for live camera frame ingestion."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.frame: QImage = None
        self.setStyleSheet(f"background-color: #000000; border: 1px solid {TacticalPalette.SURFACE_BORDER}; border-radius: 6px;")

    def update_frame(self, q_img: QImage):
        self.frame = q_img
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        if self.frame:
            scaled = self.frame.scaled(self.size(), Qt.KeepAspectRatio, Qt.SmoothTransformation)
            x = (self.width() - scaled.width()) // 2
            y = (self.height() - scaled.height()) // 2
            painter.drawImage(x, y, scaled)
        else:
            painter.fillRect(self.rect(), QColor("#0B0E14"))
            painter.setPen(QColor(TacticalPalette.TEXT_MUTED))
            painter.drawText(self.rect(), Qt.AlignCenter, "[ WAITING FOR VIDEO STREAM ]")
# src/resq_command/ui/hud/siri_orb_widget.py
import math
from PySide6.QtCore import Qt, QTimer, QRectF
from PySide6.QtGui import QPainter, QColor, QBrush, QPen, QRadialGradient
from PySide6.QtWidgets import QWidget
from resq_command.style.palette import TacticalPalette

class SiriOrbWidget(QWidget):
    """Siri/Jarvis dynamic waveform orb in Indigo & Violet."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedSize(52, 52)
        self.phase = 0.0
        self.state = "IDLE"  # IDLE, LISTENING, THINKING, EXECUTING, SPEAKING

        self.timer = QTimer(self)
        self.timer.timeout.connect(self._animate_tick)
        self.timer.start(16)  # 60 FPS

    def set_state(self, state: str):
        self.state = state
        self.update()

    def _animate_tick(self):
        speed = 0.08 if self.state in ["LISTENING", "THINKING", "EXECUTING"] else 0.04
        self.phase += speed
        if self.phase > 2 * math.pi:
            self.phase = 0.0
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        cx, cy = self.width() / 2.0, self.height() / 2.0
        r = 15.0 + 3.0 * math.sin(self.phase * 2.0)

        # Dynamic Gradient Core
        grad = QRadialGradient(cx, cy, r * 1.5)
        if self.state == "LISTENING":
            # Safety Green listening state
            grad.setColorAt(0.0, QColor(TacticalPalette.LEVEL_GREEN))
            grad.setColorAt(0.7, QColor(22, 163, 74, 90))
        elif self.state == "EXECUTING":
            # Safety Yellow / Amber executing state
            grad.setColorAt(0.0, QColor(TacticalPalette.LEVEL_YELLOW))
            grad.setColorAt(0.7, QColor(217, 119, 6, 90))
        else:
            # Sovereign Indigo -> Violet pulse
            grad.setColorAt(0.0, QColor(TacticalPalette.VIOLET_GLOW))
            grad.setColorAt(0.6, QColor(TacticalPalette.INDIGO_ACCENT))
            grad.setColorAt(0.9, QColor(79, 70, 229, 30))
        grad.setColorAt(1.0, QColor(0, 0, 0, 0))

        painter.setBrush(QBrush(grad))
        painter.setPen(Qt.NoPen)
        painter.drawEllipse(QRectF(cx - r, cy - r, r * 2, r * 2))

        # Precision outer orbital ring
        pen_color = QColor(TacticalPalette.INDIGO_ACCENT)
        pen_color.setAlpha(160)
        ring_pen = QPen(pen_color)
        ring_pen.setWidth(2)
        ring_pen.setStyle(Qt.DashLine)
        painter.setPen(ring_pen)
        painter.setBrush(Qt.NoBrush)

        outer_r = r + 6.0 + 2.0 * math.cos(self.phase * 3.0)
        painter.drawEllipse(QRectF(cx - outer_r, cy - outer_r, outer_r * 2, outer_r * 2))
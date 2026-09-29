"""
Sub-page 01: Tactical Radar Map & Fleet Telemetry.
Uses centralized StatChip HUD metrics, clean canvas rendering, and EventBus feeds.
"""

from collections import deque
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel
from PySide6.QtCore import Qt
from PySide6.QtGui import QPainter, QColor, QPen
from resq_command.style.palette import TacticalPalette
from resq_command.ui.widgets.stat_chip import StatChip


class TacticalMapCanvas(QWidget):
    """Institutional 2D Map Canvas rendering dynamic tracks and breadcrumbs."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setProperty("variant", "card")
        self.drones = {}
        self.trails = {}

    def update_drone_telemetry(self, data: dict):
        drone_id = data.get("drone_id", "UAV-01")
        self.drones[drone_id] = data

        if drone_id not in self.trails:
            self.trails[drone_id] = deque(maxlen=24)
        self.trails[drone_id].append((data.get("x", 0.0), data.get("y", 0.0)))

        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        # Base Surface
        painter.fillRect(self.rect(), QColor(TacticalPalette.BG_PANEL))

        # 1. Subtle Coordinate Grid
        grid_pen = QPen(QColor(TacticalPalette.SURFACE_BORDER_LIGHT))
        grid_pen.setStyle(Qt.DotLine)
        painter.setPen(grid_pen)
        for x in range(0, self.width(), 48):
            painter.drawLine(x, 0, x, self.height())
        for y in range(0, self.height(), 48):
            painter.drawLine(0, y, self.width(), y)

        # 2. Concentric Range Rings
        cx, cy = self.width() // 2, self.height() // 2
        painter.setPen(QPen(QColor(TacticalPalette.SURFACE_BORDER), 1, Qt.DashLine))
        for r in [90, 180, 270]:
            painter.drawEllipse(cx - r, cy - r, r * 2, r * 2)

        # 3. Breadcrumb Vector Trails
        trail_pen = QPen(QColor(TacticalPalette.INDIGO_ACCENT))
        trail_pen.setWidth(1)
        trail_pen.setStyle(Qt.DotLine)
        painter.setPen(trail_pen)
        for drone_id, pts in self.trails.items():
            for i in range(1, len(pts)):
                painter.drawLine(pts[i - 1][0], pts[i - 1][1], pts[i][0], pts[i][1])

        # 4. Active UAV Markers
        for drone_id, data in self.drones.items():
            dx, dy = int(data.get("x", cx)), int(data.get("y", cy))
            bat = data.get("battery", 100)
            status_col = TacticalPalette.LEVEL_GREEN if bat > 25 else TacticalPalette.LEVEL_RED
            status_bg = TacticalPalette.LEVEL_GREEN_BG if bat > 25 else TacticalPalette.LEVEL_RED_BG

            # Status Aura Ring
            painter.setPen(QPen(QColor(status_col), 1))
            painter.setBrush(QColor(status_bg))
            painter.drawEllipse(dx - 12, dy - 12, 24, 24)

            # Core Asset Icon
            painter.setPen(Qt.NoPen)
            painter.setBrush(QColor(TacticalPalette.INDIGO_PRIMARY))
            painter.drawEllipse(dx - 5, dy - 5, 10, 10)

            # Data Label
            painter.setPen(QColor(TacticalPalette.TEXT_PRIMARY))
            alt = data.get("altitude", 0.0)
            callsign = data.get("callsign", drone_id)
            painter.drawText(dx + 16, dy + 4, f"{callsign} [ALT: {alt:.1f}m | BAT: {bat}%]")


class LayoutMapPage(QWidget):
    """Tactical Map Workspace with institutional status badges."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root_layout = QVBoxLayout(self)
        root_layout.setContentsMargins(20, 20, 20, 20)
        root_layout.setSpacing(14)

        # Top Metric HUD Bar
        hud_bar = QHBoxLayout()
        header_title = QLabel("FIELD OPERATIONS // SECTOR A-4")
        header_title.setProperty("variant", "header")
        hud_bar.addWidget(header_title)
        hud_bar.addStretch()

        # Telemetry & Status Chips (StatChip reusable component)
        metrics = [
            ("UAV STATUS", "2 AIRBORNE", "NOMINAL"),
            ("HAZARD LEVEL", "YELLOW (ALERT)", "WARNING"),
            ("DISTRESS BEACONS", "0 ACTIVE", "NOMINAL"),
        ]

        for label, val, lvl in metrics:
            chip = StatChip(label, val, lvl, self)
            hud_bar.addWidget(chip)

        root_layout.addLayout(hud_bar)

        # Geo-Canvas Viewport
        self.canvas = TacticalMapCanvas(self)
        root_layout.addWidget(self.canvas, stretch=1)

        if self.event_bus:
            self.event_bus.telemetry_updated.connect(self.canvas.update_drone_telemetry)
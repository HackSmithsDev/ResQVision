"""
Sub-page 04: Tactical Video Matrix (CCTV, Bodycam, RTSP Streams).
Uses shared StreamCanvas viewport widgets and cards.qss styling.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QGridLayout, QFrame
from resq_command.ui.widgets.stream_canvas import StreamCanvas
from resq_command.ui.widgets.status_badge import StatusBadge


class SourcesPage(QWidget):
    """Tactical Video Matrix: UAV Gimbal, Bodycam, and RTSP Sensor Feeds."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        title = QLabel("OPTICAL & RECON FEEDS // VIDEO MATRIX")
        title.setProperty("variant", "header")
        header.addWidget(title)
        header.addStretch()
        root.addLayout(header)

        grid = QGridLayout()
        grid.setSpacing(12)

        feeds = [
            ("UAV-01 GIMBAL 4K", "1080p60 // 32ms", "NOMINAL"),
            ("TEAM ALPHA BODYCAM", "720p30 // 110ms", "NOMINAL"),
            ("PERIMETER CCTV #04", "1080p15 // 45ms", "NOMINAL"),
            ("THERMAL SENSOR 02", "VGA THERMAL // 28ms", "WARNING"),
        ]

        for i, (name, meta, status_level) in enumerate(feeds):
            feed_card = QFrame()
            feed_card.setProperty("variant", "card")
            c_lay = QVBoxLayout(feed_card)
            c_lay.setContentsMargins(10, 10, 10, 10)
            c_lay.setSpacing(8)

            # Reusable Video Canvas
            canvas = StreamCanvas(self)
            canvas.setMinimumHeight(160)
            c_lay.addWidget(canvas)

            # Card Footer with Metadata & Status Badge
            footer = QHBoxLayout()
            badge = StatusBadge(status_level, status_level)
            footer.addWidget(badge)

            name_lbl = QLabel(f"<b>{name}</b>")
            footer.addWidget(name_lbl)
            footer.addStretch()

            meta_lbl = QLabel(meta)
            meta_lbl.setProperty("variant", "meta")
            footer.addWidget(meta_lbl)
            c_lay.addLayout(footer)

            row, col = divmod(i, 2)
            grid.addWidget(feed_card, row, col)

        root.addLayout(grid)
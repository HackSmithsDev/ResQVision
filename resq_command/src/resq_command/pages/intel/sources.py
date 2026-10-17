"""
Sub-page 04: Tactical Video Matrix (CCTV, Bodycam, RTSP Streams).
Uses shared StreamCanvas viewport widgets and cards.qss styling.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QGridLayout, QFrame
from PySide6.QtMultimedia import QCameraDevice, QMediaDevices
from resq_command.api.video_client import VideoStreamClient
from resq_command.core.config import settings
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
        self.video_canvas: StreamCanvas | None = None
        self.video_badge: StatusBadge | None = None
        self.video_client: VideoStreamClient | None = None

        feeds = [
            ("LOCAL UAV VIDEO RECEIVER", "DIRECT GROUND-STATION INPUT"),
            ("TEAM ALPHA BODYCAM", "NO LOCAL INPUT CONFIGURED"),
            ("PERIMETER CCTV #04", "NO LOCAL INPUT CONFIGURED"),
            ("THERMAL SENSOR 02", "NO LOCAL INPUT CONFIGURED"),
        ]

        for i, (name, meta) in enumerate(feeds):
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
            badge = StatusBadge("NO INPUT", "MUTED")
            footer.addWidget(badge)

            name_lbl = QLabel(f"<b>{name}</b>")
            footer.addWidget(name_lbl)
            footer.addStretch()

            meta_lbl = QLabel(meta)
            meta_lbl.setProperty("variant", "meta")
            footer.addWidget(meta_lbl)
            c_lay.addLayout(footer)

            if i == 0:
                self.video_canvas = canvas
                self.video_badge = badge

            row, col = divmod(i, 2)
            grid.addWidget(feed_card, row, col)

        root.addLayout(grid)
        if event_bus:
            event_bus.settings_changed.connect(self._configure_video)
        self._configure_video()

    def _configure_video(self) -> None:
        if self.video_client:
            self.video_client.stop()
            self.video_client.deleteLater()
            self.video_client = None

        canvas = self.video_canvas
        badge = self.video_badge
        if canvas is None or badge is None:
            return

        canvas.clear_frame()
        badge.setToolTip("")
        badge.set_status("NO INPUT", "MUTED")

        video_source: str | QCameraDevice | None = None
        if settings.video_device_name:
            devices = QMediaDevices.videoInputs()
            video_source = next(
                (
                    device
                    for device in devices
                    if device.description() == settings.video_device_name
                ),
                None,
            )
            if video_source is None:
                available = ", ".join(
                    device.description() for device in devices
                ) or "none detected"
                self._show_video_error(
                    badge,
                    f"Capture device '{settings.video_device_name}' not found. "
                    f"Available devices: {available}.",
                )
        elif settings.video_stream_uri:
            video_source = settings.video_stream_uri

        if video_source is None:
            return

        badge.set_status("CONNECTING", "WARNING")
        video_client = VideoStreamClient(video_source, parent=self)
        self.video_client = video_client
        video_client.frame_ready.connect(canvas.update_frame)
        video_client.stream_active.connect(
            lambda active: badge.set_status(
                "LIVE" if active else "OFFLINE",
                "NOMINAL" if active else "MUTED",
            )
        )
        video_client.error_occurred.connect(
            lambda message: self._show_video_error(badge, message)
        )
        video_client.start()

    @staticmethod
    def _show_video_error(badge: StatusBadge, message: str) -> None:
        badge.set_status("VIDEO ERROR", "CRITICAL")
        badge.setToolTip(message)
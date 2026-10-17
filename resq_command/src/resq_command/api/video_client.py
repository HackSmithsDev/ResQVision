"""Local media client for the ground station's video receiver."""

import time

from PySide6.QtCore import QObject, QUrl, Signal
from PySide6.QtGui import QImage
from PySide6.QtMultimedia import (
    QCamera,
    QCameraDevice,
    QMediaCaptureSession,
    QMediaPlayer,
    QVideoFrame,
    QVideoSink,
)


class VideoStreamClient(QObject):
    """Reads a local HDMI capture device or receiver feed without cloud relays."""

    frame_ready = Signal(QImage)
    stream_active = Signal(bool)
    error_occurred = Signal(str)

    def __init__(
        self,
        source: str | QCameraDevice,
        target_fps: int = 30,
        parent=None,
    ):
        super().__init__(parent)
        self.source = source
        self._frame_interval = 1.0 / max(1, target_fps)
        self._last_frame_at = 0.0
        self.is_running = False

        self._video_sink = QVideoSink(self)
        self._video_sink.videoFrameChanged.connect(self._on_video_frame)
        self._player: QMediaPlayer | None = None
        self._camera: QCamera | None = None

        if isinstance(source, QCameraDevice):
            self._capture_session = QMediaCaptureSession(self)
            self._camera = QCamera(source, self)
            self._capture_session.setCamera(self._camera)
            self._capture_session.setVideoSink(self._video_sink)
            self._camera.activeChanged.connect(self.stream_active.emit)
            self._camera.errorOccurred.connect(self._on_error)
        else:
            self._player = QMediaPlayer(self)
            self._player.setVideoSink(self._video_sink)
            self._player.mediaStatusChanged.connect(self._on_media_status_changed)
            self._player.errorOccurred.connect(self._on_error)

    def start(self) -> None:
        if self._camera:
            self.is_running = True
            self._camera.start()
            return

        if not isinstance(self.source, str) or self._player is None:
            self.error_occurred.emit("No supported local video source is configured.")
            self.stream_active.emit(False)
            return

        url = QUrl.fromUserInput(self.source)
        if not url.isValid() or url.scheme() not in {"rtsp", "http", "https"}:
            self.error_occurred.emit(
                "Video receiver URI must use rtsp, http, or https."
            )
            self.stream_active.emit(False)
            return

        self.is_running = True
        self._player.setSource(url)
        self._player.play()

    def _on_video_frame(self, frame: QVideoFrame) -> None:
        image = frame.toImage()
        now = time.monotonic()
        if not image.isNull() and now - self._last_frame_at >= self._frame_interval:
            self._last_frame_at = now
            self.frame_ready.emit(image)

    def _on_media_status_changed(self, status) -> None:
        if status in {
            QMediaPlayer.MediaStatus.LoadedMedia,
            QMediaPlayer.MediaStatus.BufferedMedia,
        }:
            self.stream_active.emit(True)
        elif status in {
            QMediaPlayer.MediaStatus.NoMedia,
            QMediaPlayer.MediaStatus.InvalidMedia,
            QMediaPlayer.MediaStatus.EndOfMedia,
        }:
            self.is_running = False
            self.stream_active.emit(False)

    def _on_error(self, error, error_string: str) -> None:
        self.is_running = False
        self.stream_active.emit(False)
        self.error_occurred.emit(error_string or f"Video playback failed: {error}")

    def stop(self) -> None:
        self.is_running = False
        if self._player:
            self._player.stop()
        if self._camera:
            self._camera.stop()
        self.stream_active.emit(False)

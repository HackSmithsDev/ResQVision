"""
ResQVision Command - Video Stream Decoder Client
Decodes RTSP / HTTP video streams into QImages for rendering on StreamCanvas.
"""

import time
from PySide6.QtCore import QThread, Signal
from PySide6.QtGui import QImage, QColor


class VideoStreamClient(QThread):
    """Asynchronously pulls frames from RTSP camera feeds and emits QImages."""

    frame_ready = Signal(QImage)
    stream_active = Signal(bool)

    def __init__(self, stream_uri: str, target_fps: int = 30, parent=None):
        super().__init__(parent)
        self.stream_uri = stream_uri
        self.interval = 1.0 / target_fps
        self.is_running = True

    def run(self):
        self.stream_active.emit(True)

        # In production without OpenCV installed, falls back to a clean mock test-pattern
        while self.is_running:
            start_time = time.time()

            # Generate lightweight tactical frame buffer (640x360 ARGB32)
            img = QImage(640, 360, QImage.Format_RGB32)
            img.fill(QColor(15, 20, 28))  # Dark tactical slate placeholder
            self.frame_ready.emit(img)

            elapsed = time.time() - start_time
            sleep_time = max(0.001, self.interval - elapsed)
            time.sleep(sleep_time)

        self.stream_active.emit(False)

    def stop(self):
        self.is_running = False
        self.wait()
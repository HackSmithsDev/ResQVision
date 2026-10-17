from PySide6.QtTest import QSignalSpy

from resq_command.api.video_client import VideoStreamClient


def test_video_client_rejects_unsupported_uri(qapp) -> None:
    client = VideoStreamClient("file:///tmp/not-a-video-source")
    errors = QSignalSpy(client.error_occurred)

    client.start()

    assert errors.count() == 1
    assert "must use rtsp, http, or https" in errors.at(0)[0]

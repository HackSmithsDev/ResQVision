"""
ResQVision Command - Local UDP Telemetry Client
Ingests JSON datagrams from a local telemetry adapter and emits them on the EventBus.
"""

import json
import logging
import socket
import time
from json import JSONDecodeError

from PySide6.QtCore import QThread, Signal
from resq_command.api.client import ResQVisionAPIClient

logger = logging.getLogger(__name__)


class BackendSimulationClient(QThread):
    """Poll backend-generated demo telemetry and publish it to the UI."""

    error_occurred = Signal(str)

    def __init__(self, event_bus=None, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.is_running = False
        self.api_client = ResQVisionAPIClient()

    def run(self):
        self.is_running = True
        while self.is_running:
            try:
                packet = self.api_client.get_simulated_telemetry()
                if self.event_bus:
                    self.event_bus.telemetry_updated.emit(packet)
            except Exception as exc:
                self.error_occurred.emit(str(exc))
            time.sleep(1)

    def stop(self):
        self.is_running = False
        self.wait()


class UDPTelemetryClient(QThread):
    """Listens for JSON telemetry datagrams from the local ground-station receiver."""

    packet_received = Signal(dict)
    connection_status_changed = Signal(bool)
    error_occurred = Signal(str)

    def __init__(self, host: str = "0.0.0.0", port: int = 14550, event_bus=None, parent=None):
        super().__init__(parent)
        self.host = host
        self.port = port
        self.event_bus = event_bus
        self.is_running = False
        self.sock: socket.socket | None = None

    def run(self):
        self.is_running = True
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.bind((self.host, self.port))
            self.sock.settimeout(1.0)
            self.connection_status_changed.emit(True)
        except OSError as exc:
            self._report_error(f"Unable to bind telemetry receiver on {self.host}:{self.port}: {exc}")
            if self.sock:
                self.sock.close()
                self.sock = None
            self.connection_status_changed.emit(False)
            return

        try:
            while self.is_running:
                try:
                    data, _ = self.sock.recvfrom(4096)
                except socket.timeout:
                    continue
                except OSError as exc:
                    if self.is_running:
                        self._report_error(f"Telemetry receiver failed: {exc}")
                    break

                try:
                    packet = json.loads(data.decode("utf-8"))
                except (UnicodeDecodeError, JSONDecodeError) as exc:
                    self._report_error(f"Ignoring invalid telemetry datagram: {exc}")
                    continue

                if not isinstance(packet, dict):
                    self._report_error("Ignoring telemetry datagram: expected a JSON object.")
                    continue

                self.packet_received.emit(packet)
                if self.event_bus:
                    self.event_bus.telemetry_updated.emit(packet)
        finally:
            self.sock.close()
            self.sock = None
            self.connection_status_changed.emit(False)

    def _report_error(self, message: str) -> None:
        logger.error(message)
        self.error_occurred.emit(message)

    def stop(self):
        self.is_running = False
        self.wait()
"""
ResQVision Command - Live UDP Telemetry Client
Ingests binary/JSON MAVLink datagrams and pipes them onto the EventBus.
"""

import socket
import json
from PySide6.QtCore import QThread, Signal


class UDPTelemetryClient(QThread):
    """Listens on UDP socket for drone autopilot and sensor datagrams."""

    packet_received = Signal(dict)
    connection_status_changed = Signal(bool)

    def __init__(self, host: str = "0.0.0.0", port: int = 14550, event_bus=None, parent=None):
        super().__init__(parent)
        self.host = host
        self.port = port
        self.event_bus = event_bus
        self.is_running = False
        self.sock: socket.socket = None

    def run(self):
        self.is_running = True
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.bind((self.host, self.port))
            self.sock.settimeout(1.0)
            self.connection_status_changed.emit(True)
        except Exception:
            self.connection_status_changed.emit(False)
            return

        while self.is_running:
            try:
                data, _ = self.sock.recvfrom(4096)
                packet = json.loads(data.decode("utf-8"))
                
                self.packet_received.emit(packet)
                if self.event_bus:
                    self.event_bus.telemetry_updated.emit(packet)
            except socket.timeout:
                continue
            except Exception:
                continue

        if self.sock:
            self.sock.close()
        self.connection_status_changed.emit(False)

    def stop(self):
        self.is_running = False
        self.wait()
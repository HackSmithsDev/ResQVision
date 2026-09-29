"""
ResQVision Command - Real-time WebSocket Client
Auto-reconnecting client for push alerts and live environmental sensor data.
"""

import json
import time
from PySide6.QtCore import QThread, Signal
import websocket


class RealtimeWebSocketClient(QThread):
    """Subscribes to server-sent event feeds via persistent WebSocket."""

    alert_received = Signal(dict)
    sensor_received = Signal(dict)
    is_connected_signal = Signal(bool)

    def __init__(self, uri: str, event_bus=None, parent=None):
        super().__init__(parent)
        self.uri = uri
        self.event_bus = event_bus
        self.is_running = True
        self.ws: websocket.WebSocketApp = None

    def run(self):
        while self.is_running:
            try:
                self.ws = websocket.WebSocketApp(
                    self.uri,
                    on_open=self._on_open,
                    on_message=self._on_message,
                    on_error=self._on_error,
                    on_close=self._on_close,
                )
                self.ws.run_forever(ping_interval=15, ping_timeout=5)
            except Exception:
                pass
            
            # Reconnection backoff interval
            time.sleep(3)

    def _on_open(self, ws):
        self.is_connected_signal.emit(True)

    def _on_message(self, ws, message):
        try:
            payload = json.loads(message)
            channel = payload.get("channel", "alerts")

            if channel == "alerts":
                self.alert_received.emit(payload)
                if self.event_bus:
                    self.event_bus.alert_triggered.emit(payload)
            elif channel == "sensors":
                self.sensor_received.emit(payload)
                if self.event_bus:
                    self.event_bus.sensor_reading_updated.emit(payload)
        except Exception:
            pass

    def _on_error(self, ws, error):
        self.is_connected_signal.emit(False)

    def _on_close(self, ws, close_status_code, close_msg):
        self.is_connected_signal.emit(False)

    def stop(self):
        self.is_running = False
        if self.ws:
            self.ws.close()
        self.wait()
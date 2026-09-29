"""
ResQVision Command - Mock Telemetry Engine
Generates realistic orbiting flight paths, battery degradation, and simulated alerts.
"""

import math
import random
import time
from PySide6.QtCore import QThread, Signal


class MockTelemetryClient(QThread):
    telemetry_packet = Signal(dict)
    alert_packet = Signal(dict)

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.is_running = True
        self.tick = 0

        self.drones = {
            "UAV-01": {
                "callsign": "RECON-01",
                "center_x": 420.0,
                "center_y": 280.0,
                "radius": 140.0,
                "speed": 0.035,
                "altitude": 45.0,
                "battery": 88,
                "status": "AIRBORNE",
            },
            "UAV-02": {
                "callsign": "THERMAL-02",
                "center_x": 260.0,
                "center_y": 380.0,
                "radius": 90.0,
                "speed": -0.025,
                "altitude": 38.0,
                "battery": 64,
                "status": "SEARCHING",
            }
        }

    def run(self):
        while self.is_running:
            self.tick += 1

            for uav_id, state in self.drones.items():
                angle = self.tick * state["speed"]
                curr_x = state["center_x"] + state["radius"] * math.cos(angle)
                curr_y = state["center_y"] + state["radius"] * math.sin(angle)

                if self.tick % 80 == 0 and state["battery"] > 10:
                    state["battery"] -= 1

                payload = {
                    "drone_id": uav_id,
                    "callsign": state["callsign"],
                    "x": curr_x,
                    "y": curr_y,
                    "altitude": state["altitude"] + math.sin(self.tick * 0.1) * 1.5,
                    "battery": state["battery"],
                    "ground_speed": abs(state["speed"] * 300) + random.uniform(-0.5, 0.5),
                    "status": state["status"],
                }

                self.telemetry_packet.emit(payload)
                if self.event_bus:
                    self.event_bus.telemetry_updated.emit(payload)

            if self.tick % 150 == 0:
                self._dispatch_simulated_alert()

            time.sleep(0.1)

    def _dispatch_simulated_alert(self):
        sample_alerts = [
            {
                "severity": "ALERT",
                "title": "THERMAL ANOMALY IN SECTOR A-4",
                "desc": "Heat signature detected under debris canopy (Possible survivor).",
                "timestamp": time.strftime("%H:%M:%S"),
            },
            {
                "severity": "CRITICAL",
                "title": "GEOFENCE PROXIMITY WARNING",
                "desc": "UAV-01 within 40m of restricted chemical spill perimeter.",
                "timestamp": time.strftime("%H:%M:%S"),
            },
            {
                "severity": "INFO",
                "title": "LORA PACKET RECOVERY 100%",
                "desc": "Field repeater node re-established high-SNR uplink.",
                "timestamp": time.strftime("%H:%M:%S"),
            }
        ]
        alert = random.choice(sample_alerts)
        self.alert_packet.emit(alert)
        if self.event_bus:
            self.event_bus.alert_triggered.emit(alert)

    def stop(self):
        self.is_running = False
        self.wait()
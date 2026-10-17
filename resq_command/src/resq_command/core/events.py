"""
ResQVision Command - Central Event Bus
Decouples UI consumers from telemetry ingestion, radio decoders, and AI agents.
"""

from PySide6.QtCore import QObject, Signal


class EventBus(QObject):
    """
    Singleton event bus routing Qt signals across modules.
    All background threads emit signals onto this bus to safely cross thread boundaries.
    """

    # --- Navigation & Category Switching ---
    navigate_requested = Signal(str, int)  # (category_id, sub_page_index)
    settings_changed = Signal()

    # --- Telemetry & Sensor Ingestion ---
    telemetry_updated = Signal(dict)       # Ingests DroneTelemetry dict
    sensor_reading_updated = Signal(dict)  # Ingests EnvironmentalReading dict
    mesh_status_updated = Signal(dict)     # Ingests MeshNode telemetry dict

    # --- Alerts & Safety Triggers ---
    alert_triggered = Signal(dict)         # Ingests NotificationAlert dict
    alert_count_changed = Signal(int)      # Updates global alert badges
    emergency_kill_dispatched = Signal(str) # (drone_id) -> Trigger hardware disarm

    # --- Jarvis AI & Voice Copilot Engine ---
    jarvis_state_changed = Signal(str)     # IDLE, LISTENING, THINKING, EXECUTING, SPEAKING
    jarvis_speech_recognized = Signal(str) # Transcribed operator voice query
    jarvis_response_generated = Signal(str)# Generated Jarvis reply text
    jarvis_action_dispatched = Signal(str, dict) # (action_name, parameters)

    # --- Hardware & Comms Link Status ---
    telemetry_stream_loss = Signal(str)         # (drone_id) -> Signal loss alert
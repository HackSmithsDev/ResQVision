"""
ResQVision Command - Core Constants
Immutable system parameters, safety limits, and protocol defaults.
"""

from typing import Final

# --- Application Metadata ---
APP_NAME: Final[str] = "ResQVision Command"
APP_ORG: Final[str] = "ResQVision"
APP_VERSION: Final[str] = "0.1.0"

# --- Telemetry & Refresh Frequencies ---
CANVAS_FPS: Final[int] = 60
SIMULATION_TICK_HZ: Final[int] = 10       # 100ms telemetry update loop
ALERT_TICKER_INTERVAL_MS: Final[int] = 15000
VOICE_ORB_FPS: Final[int] = 60

# --- Flight Safety Thresholds ---
BATTERY_CRITICAL_PCT: Final[int] = 20
BATTERY_WARNING_PCT: Final[int] = 35
MAX_OPERATIONAL_ALTITUDE_M: Final[float] = 120.0  # Regulatory AGL ceiling
GEOFENCE_PROXIMITY_ALERT_M: Final[float] = 50.0   # Buffer trigger before breach

# --- Network & Hardware Port Defaults ---
DEFAULT_MAVLINK_UDP_PORT: Final[int] = 14550
DEFAULT_RTSP_BASE_PORT: Final[int] = 8554
DEFAULT_LORA_BAUDRATE: Final[int] = 115200
DEFAULT_LORA_FREQUENCY_MHZ: Final[float] = 915.0

# --- Triage Priority Levels ---
PRIORITY_CRITICAL: Final[str] = "CRITICAL"
PRIORITY_URGENT: Final[str] = "URGENT"
PRIORITY_MINOR: Final[str] = "MINOR"

# --- Voice & Copilot States ---
JARVIS_STATE_IDLE: Final[str] = "IDLE"
JARVIS_STATE_LISTENING: Final[str] = "LISTENING"
JARVIS_STATE_THINKING: Final[str] = "THINKING"
JARVIS_STATE_EXECUTING: Final[str] = "EXECUTING"
JARVIS_STATE_SPEAKING: Final[str] = "SPEAKING"

# --- Workspace Identifiers ---
CATEGORY_TACTICAL: Final[str] = "tactical"
CATEGORY_INTEL: Final[str] = "intel"
CATEGORY_LOGISTICS: Final[str] = "logistics"
CATEGORY_COMMAND: Final[str] = "command"
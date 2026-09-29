"""
Core package for ResQVision Command.
Exposes runtime configuration, constants, and the central EventBus.
"""

from resq_command.core.constants import (
    APP_NAME,
    APP_ORG,
    APP_VERSION,
    CANVAS_FPS,
    SIMULATION_TICK_HZ,
    BATTERY_CRITICAL_PCT,
    BATTERY_WARNING_PCT,
    JARVIS_STATE_IDLE,
    JARVIS_STATE_LISTENING,
    JARVIS_STATE_THINKING,
    JARVIS_STATE_EXECUTING,
    JARVIS_STATE_SPEAKING,
)
from resq_command.core.config import AppConfig, settings
from resq_command.core.events import EventBus

__all__ = [
    "APP_NAME",
    "APP_ORG",
    "APP_VERSION",
    "CANVAS_FPS",
    "SIMULATION_TICK_HZ",
    "BATTERY_CRITICAL_PCT",
    "BATTERY_WARNING_PCT",
    "JARVIS_STATE_IDLE",
    "JARVIS_STATE_LISTENING",
    "JARVIS_STATE_THINKING",
    "JARVIS_STATE_EXECUTING",
    "JARVIS_STATE_SPEAKING",
    "AppConfig",
    "settings",
    "EventBus",
]
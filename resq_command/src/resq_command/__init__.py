"""
ResQVision Command (resq_command)
Tactical Ground Station & Autonomous Emergency Response Controller.
"""

from typing import List

__version__ = "0.1.0"
__author__ = "ResQVision Team"
__all__: List[str] = [
    "__version__",
    "__author__",
    "AppShell",
    "EventBus",
]

# Expose core runtime primitives for consumers, test harnesses, and main.py
from resq_command.core.events import EventBus
from resq_command.ui.app_shell import AppShell
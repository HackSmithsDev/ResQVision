"""
ResQVision Command Entry Point
Bootstraps the QApplication, Theme Engine, Central Event Bus, and Simulation Thread.
"""

import sys
from pathlib import Path

# Ensure the 'src' directory is discoverable when executing directly as a script
SRC_DIR = Path(__file__).resolve().parent / "src"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from PySide6.QtWidgets import QApplication
from resq_command import AppShell, EventBus
from resq_command.api.mock_client import MockTelemetryClient
from resq_command.style.theme_manager import ThemeManager


def main():
    # 1. Initialize Qt Application runtime
    app = QApplication(sys.argv)
    app.setApplicationName("ResQVision Command")
    app.setOrganizationName("ResQVision")

    # 2. Compile and apply global tactical QSS stylesheet
    ThemeManager.apply_theme(app)

    # 3. Instantiate central Signal/Event Bus
    event_bus = EventBus()

    # 4. Construct and display Root AppShell Window
    shell = AppShell(event_bus)
    shell.show()

    # 5. Launch Background Telemetry & Alert Simulator Thread
    mock_sim = MockTelemetryClient(event_bus)
    mock_sim.start()

    # 6. Ensure clean background thread termination on exit
    app.aboutToQuit.connect(mock_sim.stop)

    # 7. Start the main event loop
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
"""
ResQVision Command Entry Point
Bootstraps the QApplication, Theme Engine, Central Event Bus, and local telemetry input.
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
from resq_command.api.telemetry_client import UDPTelemetryClient
from resq_command.core.config import settings
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

    # 5. Use simulated telemetry for demos or listen to the local receiver.
    telemetry_client = None

    def restart_telemetry_client():
        nonlocal telemetry_client
        if telemetry_client is not None:
            telemetry_client.stop()

        if settings.enable_mock_simulator:
            telemetry_client = MockTelemetryClient(event_bus)
        else:
            telemetry_client = UDPTelemetryClient(
                host="0.0.0.0",
                port=settings.telemetry_udp_port,
                event_bus=event_bus,
            )
        telemetry_client.start()

    def stop_telemetry_client():
        if telemetry_client is not None:
            telemetry_client.stop()

    event_bus.settings_changed.connect(restart_telemetry_client)
    restart_telemetry_client()

    # 6. Ensure clean background thread termination on exit.
    app.aboutToQuit.connect(stop_telemetry_client)

    # 7. Start the main event loop
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
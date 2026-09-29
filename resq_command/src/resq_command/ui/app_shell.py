from PySide6.QtWidgets import QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QStackedWidget
from resq_command.ui.hud.ai_screening_bar import AIScreeningBar
from resq_command.ui.panels.nav_rail import NavRail
from resq_command.ui.panels.audio_ptt_strip import AudioPTTStrip
from resq_command.ui.panels.quick_telemetry_bar import QuickTelemetryBar
from resq_command.pages.tactical.category_shell import TacticalCategoryShell
from resq_command.pages.intel.category_shell import IntelCategoryShell
from resq_command.pages.logistics.category_shell import LogisticsCategoryShell
from resq_command.pages.command.category_shell import CommandCategoryShell

class AppShell(QMainWindow):
    """Root Application Shell anchoring Top HUD, NavRail, telemetry dock, and pages."""

    def __init__(self, event_bus):
        super().__init__()
        self.event_bus = event_bus
        self.setWindowTitle("ResQVision Command // Tactical Ground Station")
        self.resize(1440, 900)

        root_widget = QWidget(self)
        self.setCentralWidget(root_widget)
        root_layout = QVBoxLayout(root_widget)
        root_layout.setContentsMargins(0, 0, 0, 0)
        root_layout.setSpacing(0)

        # 1. Pinned Top AI Screening HUD Bar
        self.hud = AIScreeningBar(self.event_bus, self)
        root_layout.addWidget(self.hud)

        # 2. Body Area
        body_layout = QHBoxLayout()
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)

        # Left Nav Rail
        self.nav_rail = NavRail(self)
        body_layout.addWidget(self.nav_rail)

        # Center Category Workspaces Stack
        self.page_stack = QStackedWidget(self)
        self.tactical_shell = TacticalCategoryShell(self.event_bus, self)
        self.intel_shell = IntelCategoryShell(self.event_bus, self)
        self.logistics_shell = LogisticsCategoryShell(self.event_bus, self)
        self.command_shell = CommandCategoryShell(self.event_bus, self)

        self.page_stack.addWidget(self.tactical_shell)
        self.page_stack.addWidget(self.intel_shell)
        self.page_stack.addWidget(self.logistics_shell)
        self.page_stack.addWidget(self.command_shell)

        self.nav_rail.category_selected.connect(self.page_stack.setCurrentIndex)
        body_layout.addWidget(self.page_stack)

        # Right Quick Telemetry Dock
        self.telemetry_dock = QuickTelemetryBar(self)
        body_layout.addWidget(self.telemetry_dock)
        root_layout.addLayout(body_layout)

        # 3. Bottom PTT Strip
        self.ptt_strip = AudioPTTStrip(self.event_bus, self)
        root_layout.addWidget(self.ptt_strip)

        # Wire live telemetry into the dock
        if self.event_bus:
            self.event_bus.telemetry_updated.connect(self.telemetry_dock.update_telemetry)
from PySide6.QtWidgets import QWidget, QVBoxLayout, QStackedWidget
from resq_command.ui.panels.sub_nav_bar import SubNavBar
from resq_command.pages.command.incident_risks import IncidentRisksPage
from resq_command.pages.command.mission_protocol import MissionProtocolPage
from resq_command.pages.command.system_config import SystemConfigPage


class CommandCategoryShell(QWidget):
    CATEGORY_ID = "command"

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        tabs = [
            ("INCIDENTS & RISKS (SOS)", 0),
            ("MISSION PROTOCOLS (SOPS)", 1),
            ("SYSTEM CONFIG & PORTS", 2),
        ]
        self.sub_nav = SubNavBar(tabs, self)
        layout.addWidget(self.sub_nav)

        self.stack = QStackedWidget(self)
        self.incidents_page = IncidentRisksPage(event_bus, self)
        self.protocols_page = MissionProtocolPage(event_bus, self)
        self.config_page = SystemConfigPage(event_bus, self)

        self.stack.addWidget(self.incidents_page)
        self.stack.addWidget(self.protocols_page)
        self.stack.addWidget(self.config_page)

        layout.addWidget(self.stack)
        self.sub_nav.sub_page_changed.connect(self.stack.setCurrentIndex)
"""
Category Shell for Intel: Hosts Sources, Environment, and Notifications.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QStackedWidget
from resq_command.ui.panels.sub_nav_bar import SubNavBar
from resq_command.pages.intel.sources import SourcesPage
from resq_command.pages.intel.environment import EnvironmentPage
from resq_command.pages.intel.notifications import NotificationsPage


class IntelCategoryShell(QWidget):
    CATEGORY_ID = "intel"

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        tabs = [
            ("OPTICAL FEEDS (SOURCES)", 0),
            ("ENVIRONMENT & SENSORS", 1),
            ("ALERT QUEUE (NOTIFICATIONS)", 2),
        ]
        self.sub_nav = SubNavBar(tabs, self)
        layout.addWidget(self.sub_nav)

        self.stack = QStackedWidget(self)
        self.sources_page = SourcesPage(event_bus, self)
        self.env_page = EnvironmentPage(event_bus, self)
        self.notifications_page = NotificationsPage(event_bus, self)

        self.stack.addWidget(self.sources_page)
        self.stack.addWidget(self.env_page)
        self.stack.addWidget(self.notifications_page)

        layout.addWidget(self.stack)
        self.sub_nav.sub_page_changed.connect(self.stack.setCurrentIndex)
"""
Tactical Category Shell: Hosts Tactical Map, Drones Fleet, and Rescue Squads.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QStackedWidget
from resq_command.ui.panels.sub_nav_bar import SubNavBar
from resq_command.pages.tactical.layout_map import LayoutMapPage
from resq_command.pages.tactical.drones import DronesPage
from resq_command.pages.tactical.rescue_teams import RescueTeamsPage


class TacticalCategoryShell(QWidget):
    CATEGORY_ID = "tactical"

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        tabs = [
            ("TACTICAL MAP", 0),
            ("UAV FLEET (DRONES)", 1),
            ("RESCUE SQUADS", 2),
        ]
        self.sub_nav = SubNavBar(tabs, self)
        layout.addWidget(self.sub_nav)

        self.stack = QStackedWidget(self)
        self.layout_map = LayoutMapPage(event_bus, self)
        self.drones = DronesPage(event_bus, self)
        self.rescue_teams = RescueTeamsPage(event_bus, self)

        self.stack.addWidget(self.layout_map)
        self.stack.addWidget(self.drones)
        self.stack.addWidget(self.rescue_teams)

        layout.addWidget(self.stack)
        self.sub_nav.sub_page_changed.connect(self.stack.setCurrentIndex)
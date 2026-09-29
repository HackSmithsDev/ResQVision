"""
Category Shell for Logistics: Hosts Inventory and Comms Mesh workspaces.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QStackedWidget
from resq_command.ui.panels.sub_nav_bar import SubNavBar
from resq_command.pages.logistics.inventory import InventoryPage
from resq_command.pages.logistics.comms_mesh import CommsMeshPage


class LogisticsCategoryShell(QWidget):
    CATEGORY_ID = "logistics"

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        tabs = [
            ("DEPOT & INVENTORY", 0),
            ("COMMS MESH (LORA/RF)", 1),
        ]
        self.sub_nav = SubNavBar(tabs, self)
        layout.addWidget(self.sub_nav)

        self.stack = QStackedWidget(self)
        self.inventory_page = InventoryPage(event_bus, self)
        self.mesh_page = CommsMeshPage(event_bus, self)

        self.stack.addWidget(self.inventory_page)
        self.stack.addWidget(self.mesh_page)

        layout.addWidget(self.stack)
        self.sub_nav.sub_page_changed.connect(self.stack.setCurrentIndex)
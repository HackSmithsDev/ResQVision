"""
Sub-page 07: Depot Stock, Medical Packs & Battery Charging Bench.
Styled via global tables.qss, inputs.qss, and reusable StatChip components.
"""

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget,
    QTableWidgetItem, QHeaderView, QLineEdit
)
from PySide6.QtCore import Qt
from resq_command.ui.widgets.stat_chip import StatChip


class InventoryPage(QWidget):
    """Logistics Depot Stock, First-Aid Kits & LiPo Charging Bench."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        # Header with Summary & Search
        header = QHBoxLayout()
        header_title = QLabel("LOGISTICS DEPOT // HARDWARE & SUPPLY INVENTORY")
        header_title.setProperty("variant", "header")
        header.addWidget(header_title)
        header.addStretch()

        self.search_bar = QLineEdit()
        self.search_bar.setPlaceholderText("Filter equipment or bin...")
        self.search_bar.setFixedWidth(240)
        self.search_bar.textChanged.connect(self._filter_table)
        header.addWidget(self.search_bar)
        root.addLayout(header)

        # Summary Metric Chips
        stats_strip = QHBoxLayout()
        stat_cards = [
            ("TOTAL SKUS", "38 ITEMS", "NOMINAL"),
            ("LIPO PACKS", "14 CHARGED", "NOMINAL"),
            ("TRAUMA KITS", "8 IN FIELD", "WARNING"),
            ("RESTOCK DUE", "2 CRITICAL", "CRITICAL"),
        ]
        for title, val, level in stat_cards:
            chip = StatChip(title, val, level, self)
            stats_strip.addWidget(chip)
        stats_strip.addStretch()
        root.addLayout(stats_strip)

        # High-Density Tactical Table (relies on tables.qss)
        self.items_data = [
            ("LIPO-6S-01", "Drone Flight Battery 22000mAh", "BENCH A-1", "6 UNITS", "100% READY"),
            ("LIPO-6S-02", "Drone Flight Battery 22000mAh", "BENCH A-2", "2 UNITS", "54% CHARGING"),
            ("MED-KIT-ADV", "Level 3 Tactical Trauma Pack", "STORAGE BIN 4", "14 UNITS", "SEALED / INSPECTED"),
            ("LORA-NODE-EXT", "Deployable Relay Pods (915MHz)", "RACK C-3", "8 UNITS", "BENCH TESTED"),
            ("HAZMAT-RESP", "Full-Face Respirators + Filters", "STORAGE BIN 2", "20 UNITS", "READY"),
            ("STRETCHER-FOLD", "Carbon Fiber Basket Stretcher", "HANGAR SEC-1", "4 UNITS", "FIELD DEPLOYED"),
            ("RATION-PACK-72", "72-Hr Emergency Calorie Bins", "RACK B-2", "30 PACKS", "RESTOCK DUE"),
        ]

        self.table = QTableWidget(len(self.items_data), 5, self)
        self.table.setHorizontalHeaderLabels([
            "ITEM CODE", "EQUIPMENT SPECIFICATION", "STORAGE BIN", "AVAILABLE QTY", "CHARGE / STATUS"
        ])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.verticalHeader().setVisible(False)
        self.table.setAlternatingRowColors(True)

        self._populate_table()
        root.addWidget(self.table)

    def _populate_table(self):
        for row, row_data in enumerate(self.items_data):
            for col, text in enumerate(row_data):
                item = QTableWidgetItem(text)
                if col in [0, 2]:
                    item.setForeground(Qt.GlobalColor.darkGray)
                self.table.setItem(row, col, item)

    def _filter_table(self, query: str):
        query = query.lower()
        for r in range(self.table.rowCount()):
            code = self.table.item(r, 0).text().lower()
            name = self.table.item(r, 1).text().lower()
            bin_loc = self.table.item(r, 2).text().lower()
            match = query in code or query in name or query in bin_loc
            self.table.setRowHidden(r, not match)
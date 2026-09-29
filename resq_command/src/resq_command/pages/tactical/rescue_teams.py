"""
Sub-page 03: Field Responder Squad Roster & Live Vitals.
Styled completely via centralized tables.qss without inline overrides.
"""

from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QHeaderView
from PySide6.QtCore import Qt


class RescueTeamsPage(QWidget):
    """Field Responder Squad Roster & Live Biometrics."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        # Header
        header = QHBoxLayout()
        header_title = QLabel("FIELD TEAMS // BIOMETRICS & ASSIGNMENTS")
        header_title.setProperty("variant", "header")
        header.addWidget(header_title)
        header.addStretch()
        root.addLayout(header)

        # Tactical Table (inherits tables.qss styling)
        self.table = QTableWidget(4, 5, self)
        self.table.setHorizontalHeaderLabels(["CALLSIGN", "ROLE", "ZONE ASSIGNED", "HEART RATE", "STATUS"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.verticalHeader().setVisible(False)
        self.table.setAlternatingRowColors(True)

        teams_data = [
            ("TEAM ALPHA", "HAZMAT SEARCH", "SECTOR A-04", "88 BPM", "NOMINAL"),
            ("TEAM BRAVO", "EVAC DISPATCH", "SECTOR B-12", "112 BPM", "ACTIVE ASSIST"),
            ("TEAM CHARLIE", "MEDICAL TRIAGE", "BASE CAMP", "72 BPM", "STANDBY"),
            ("TEAM DELTA", "SWIFT WATER", "RIVER BASIN", "98 BPM", "SEARCHING"),
        ]

        for row, row_vals in enumerate(teams_data):
            for col, val in enumerate(row_vals):
                item = QTableWidgetItem(val)
                if col in [0, 4]:
                    item.setTextAlignment(Qt.AlignCenter)
                self.table.setItem(row, col, item)

        root.addWidget(self.table)
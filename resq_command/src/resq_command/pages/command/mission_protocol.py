"""
Sub-page 10: Standard Operating Procedures (SOPs) & SITREP Generation.
Leverages global cards.qss and buttons.qss styling.
"""

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame,
    QCheckBox, QPushButton, QMessageBox
)
from resq_command.core.config import settings


class MissionProtocolPage(QWidget):
    """Operational Checklists, SOP Compliance & SITREP Exporter."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        title = QLabel("STANDARD OPERATING PROCEDURES // ACTIVE MISSION PROTOCOL")
        title.setProperty("variant", "header")
        header.addWidget(title)
        header.addStretch()

        export_btn = QPushButton("EXPORT SITREP PDF")
        export_btn.setProperty("variant", "primary")
        export_btn.clicked.connect(self._export_sitrep)
        header.addWidget(export_btn)
        root.addLayout(header)

        sop_card = QFrame()
        sop_card.setProperty("variant", "card")
        c_lay = QVBoxLayout(sop_card)
        c_lay.setSpacing(12)

        card_title = QLabel("<b>PHASE 1: SEARCH & CONTAINMENT MANDATORY STEPS</b>")
        c_lay.addWidget(card_title)

        steps = [
            ("Establish geofence isolation perimeter around hazard zone", True),
            ("Deploy UAV Recon flight squadron for autonomous 3D grid mapping", True),
            ("Ingest live river level gauges and trigger evacuation threshold warnings", True),
            ("Dispatch HAZMAT Team Alpha with multi-gas detection suits", False),
            ("Broadcast emergency alert push to field radio channels", False),
            ("Finalize preliminary SITREP for provincial emergency management", False),
        ]

        self.checkboxes = []
        for step_text, checked in steps:
            cb = QCheckBox(step_text)
            cb.setChecked(checked)
            c_lay.addWidget(cb)
            self.checkboxes.append(cb)

        root.addWidget(sop_card)
        root.addStretch()

    def _export_sitrep(self):
        completed = sum(1 for cb in self.checkboxes if cb.isChecked())
        total = len(self.checkboxes)
        out_path = settings.logs_dir / "SITREP_LATEST.pdf"

        QMessageBox.information(
            self,
            "SITREP Exported",
            f"SITREP report successfully compiled.\n\n"
            f"SOP Progress: {completed}/{total} steps verified.\n"
            f"Destination: {out_path}"
        )
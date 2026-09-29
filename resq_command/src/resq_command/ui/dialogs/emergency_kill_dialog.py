from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QCheckBox
from resq_command.style.palette import TacticalPalette

class EmergencyKillDialog(QDialog):
    """Two-stage armed UAV flight termination confirmation modal."""

    def __init__(self, drone_id: str = "UAV-01", parent=None):
        super().__init__(parent)
        self.setWindowTitle("EMERGENCY KILL SWITCH // CONFIRM TERMINATION")
        self.setFixedSize(420, 220)
        self.setStyleSheet(f"background-color: {TacticalPalette.BG_PANEL};")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(14)

        warn_title = QLabel(f"WARNING: TERMINATE {drone_id} IMMEDIATELY?")
        warn_title.setStyleSheet(f"color: {TacticalPalette.LEVEL_RED}; font-size: 14px; font-weight: 800;")
        layout.addWidget(warn_title)

        desc = QLabel(
            "This command immediately disarms all ESC motors in mid-air. "
            "The aircraft will fall immediately. Use only to protect human life on the ground."
        )
        desc.setWordWrap(True)
        desc.setStyleSheet(f"color: {TacticalPalette.TEXT_SECONDARY}; font-size: 12px;")
        layout.addWidget(desc)

        self.confirm_chk = QCheckBox("I understand this will cause catastrophic vehicle damage.")
        self.confirm_chk.toggled.connect(self._toggle_arm)
        layout.addWidget(self.confirm_chk)

        # Buttons
        btn_box = QHBoxLayout()
        cancel_btn = QPushButton("ABORT")
        cancel_btn.clicked.connect(self.reject)
        btn_box.addWidget(cancel_btn)

        self.kill_btn = QPushButton("CONFIRM VEHICLE TERMINATE")
        self.kill_btn.setEnabled(False)
        self.kill_btn.setStyleSheet(f"""
            QPushButton {{
                background-color: {TacticalPalette.LEVEL_RED};
                color: #FFFFFF;
                font-weight: 800;
            }}
            QPushButton:disabled {{
                background-color: {TacticalPalette.BG_CARD};
                color: {TacticalPalette.TEXT_MUTED};
            }}
        """)
        self.kill_btn.clicked.connect(self.accept)
        btn_box.addWidget(self.kill_btn)

        layout.addLayout(btn_box)

    def _toggle_arm(self, checked: bool):
        self.kill_btn.setEnabled(checked)
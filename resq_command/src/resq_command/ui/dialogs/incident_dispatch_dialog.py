from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QComboBox, QTextEdit, QPushButton
from resq_command.style.palette import TacticalPalette

class IncidentDispatchDialog(QDialog):
    """Modal to log and dispatch manual SOS incident tickets."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("NEW INCIDENT DISPATCH TICKET")
        self.setFixedSize(440, 360)
        self.setStyleSheet(f"background-color: {TacticalPalette.BG_PANEL};")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(10)

        layout.addWidget(QLabel("INCIDENT TITLE:"))
        self.title_input = QLineEdit()
        self.title_input.setPlaceholderText("e.g., Flash Flood Evacuation Request")
        layout.addWidget(self.title_input)

        layout.addWidget(QLabel("TRIAGE PRIORITY LEVEL:"))
        self.prio_combo = QComboBox()
        self.prio_combo.addItems(["CRITICAL (RED)", "URGENT (YELLOW)", "MINOR (GREEN)"])
        layout.addWidget(self.prio_combo)

        layout.addWidget(QLabel("DESCRIPTION / SITUATION:"))
        self.desc_input = QTextEdit()
        self.desc_input.setPlaceholderText("Enter details, landmarks, or caller phone number...")
        layout.addWidget(self.desc_input)

        btn_box = QHBoxLayout()
        cancel = QPushButton("CANCEL")
        cancel.clicked.connect(self.reject)
        btn_box.addWidget(cancel)

        dispatch = QPushButton("DISPATCH INCIDENT")
        dispatch.setStyleSheet(f"background-color: {TacticalPalette.INDIGO_ACCENT}; color: #FFFFFF; font-weight: 700;")
        dispatch.clicked.connect(self.accept)
        btn_box.addWidget(dispatch)

        layout.addLayout(btn_box)

    def get_data(self) -> dict:
        return {
            "title": self.title_input.text(),
            "priority": self.prio_combo.currentText(),
            "description": self.desc_input.toPlainText(),
        }
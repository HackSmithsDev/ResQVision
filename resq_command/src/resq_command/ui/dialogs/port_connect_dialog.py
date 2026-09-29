from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QComboBox, QPushButton
from resq_command.style.palette import TacticalPalette

class PortConnectDialog(QDialog):
    """Direct serial COM port selection modal for field telemetry dongles."""

    def __init__(self, available_ports: list[str] = None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("CONNECT HARDWARE PORT")
        self.setFixedSize(360, 180)
        self.setStyleSheet(f"background-color: {TacticalPalette.BG_PANEL};")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(12)

        layout.addWidget(QLabel("SELECT SERIAL COM PORT:"))
        self.combo = QComboBox()
        ports = available_ports or ["/dev/cu.usbserial-110", "/dev/ttyUSB0", "COM3"]
        self.combo.addItems(ports)
        layout.addWidget(self.combo)

        btn_box = QHBoxLayout()
        cancel = QPushButton("CANCEL")
        cancel.clicked.connect(self.reject)
        btn_box.addWidget(cancel)

        connect = QPushButton("CONNECT")
        connect.setStyleSheet(f"background-color: {TacticalPalette.INDIGO_ACCENT}; color: #FFFFFF; font-weight: 700;")
        connect.clicked.connect(self.accept)
        btn_box.addWidget(connect)

        layout.addLayout(btn_box)

    def get_selected_port(self) -> str:
        return self.combo.currentText()
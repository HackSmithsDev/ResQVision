"""
Sub-page 11: Hardware Serial Ports, Sockets & Mock Simulation Harness.
Relies on inputs.qss, buttons.qss, and cards.qss without inline styles.
"""

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame,
    QLineEdit, QPushButton, QComboBox, QMessageBox
)
from resq_command.core.config import settings


class SystemConfigPage(QWidget):
    """Hardware Serial Ports, Sockets & Mock Simulation Harness."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        title = QLabel("SYSTEM CONFIGURATION // HARDWARE & NETWORK BINDINGS")
        title.setProperty("variant", "header")
        header.addWidget(title)
        header.addStretch()
        root.addLayout(header)

        card = QFrame()
        card.setProperty("variant", "card")
        c_lay = QVBoxLayout(card)
        c_lay.setSpacing(14)

        # Serial COM Port
        c_lay.addWidget(QLabel("PRIMARY LORA / RF FIELD SERIAL PORT:"))
        self.port_combo = QComboBox()
        self.port_combo.addItems([
            settings.lora_serial_port,
            "/dev/ttyUSB0 (Linux FTDI)",
            "COM3 (Windows RF Dongle)",
        ])
        c_lay.addWidget(self.port_combo)

        # UDP Telemetry Port
        c_lay.addWidget(QLabel("DRONE MAVLINK / UDP TELEMETRY PORT:"))
        self.udp_input = QLineEdit(str(settings.mavlink_udp_port))
        c_lay.addWidget(self.udp_input)

        # Mock Simulation
        c_lay.addWidget(QLabel("OFFLINE SIMULATION HARNESS:"))
        self.sim_combo = QComboBox()
        sim_default_idx = 0 if settings.enable_mock_simulator else 1
        self.sim_combo.addItems([
            "ENABLED (Running Live Mock Client)",
            "DISABLED (Listen for Real Hardware Only)",
        ])
        self.sim_combo.setCurrentIndex(sim_default_idx)
        c_lay.addWidget(self.sim_combo)

        save_btn = QPushButton("SAVE HARDWARE BINDINGS")
        save_btn.setProperty("variant", "primary")
        save_btn.clicked.connect(self._save_config)
        c_lay.addWidget(save_btn)

        root.addWidget(card)
        root.addStretch()

    def _save_config(self):
        port = self.port_combo.currentText()
        udp = self.udp_input.text()

        settings.lora_serial_port = port.split()[0]
        try:
            settings.mavlink_udp_port = int(udp)
        except ValueError:
            pass

        if self.event_bus:
            self.event_bus.serial_port_connected.emit(settings.lora_serial_port, True)

        QMessageBox.information(
            self,
            "Hardware Configuration Saved",
            f"Serial Port: {port}\nUDP Port: {udp}\n\nBindings applied to runtime engine."
        )
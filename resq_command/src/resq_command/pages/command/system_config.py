"""Ground-station telemetry and direct video input configuration."""

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame,
    QLineEdit, QPushButton, QComboBox, QMessageBox
)
from resq_command.core.config import settings


class SystemConfigPage(QWidget):
    """Ground-station telemetry and direct video input configuration."""

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

        c_lay.addWidget(
            QLabel("ELRS 2.4 GHz REMOTE → RECEIVER ON FC (DIRECT RADIO LINK)")
        )

        # This listener accepts local adapter output; it is not the ELRS link.
        c_lay.addWidget(QLabel("LOCAL JSON / UDP TELEMETRY INPUT PORT:"))
        self.udp_input = QLineEdit(str(settings.telemetry_udp_port))
        c_lay.addWidget(self.udp_input)

        c_lay.addWidget(QLabel("HDMI CAPTURE DEVICE NAME:"))
        self.video_device_input = QLineEdit(settings.video_device_name or "")
        self.video_device_input.setPlaceholderText("Exact OS camera/device name")
        c_lay.addWidget(self.video_device_input)

        # Mock Simulation
        c_lay.addWidget(QLabel("OFFLINE SIMULATION HARNESS:"))
        self.sim_combo = QComboBox()
        sim_default_idx = 0 if settings.enable_mock_simulator else 1
        self.sim_combo.addItems([
            "ENABLED (Simulated Telemetry)",
            "DISABLED (Listen for Local JSON/UDP Input)",
        ])
        self.sim_combo.setCurrentIndex(sim_default_idx)
        c_lay.addWidget(self.sim_combo)

        save_btn = QPushButton("APPLY GROUND-STATION SETTINGS")
        save_btn.setProperty("variant", "primary")
        save_btn.clicked.connect(self._save_config)
        c_lay.addWidget(save_btn)

        root.addWidget(card)
        root.addStretch()

    def _save_config(self):
        udp = self.udp_input.text().strip()
        try:
            udp_port = int(udp)
        except ValueError:
            QMessageBox.warning(self, "Invalid telemetry port", "Enter a UDP port from 1 to 65535.")
            return

        if not 1 <= udp_port <= 65535:
            QMessageBox.warning(self, "Invalid telemetry port", "Enter a UDP port from 1 to 65535.")
            return

        settings.telemetry_udp_port = udp_port
        settings.video_device_name = self.video_device_input.text().strip() or None
        settings.enable_mock_simulator = self.sim_combo.currentIndex() == 0
        if self.event_bus:
            self.event_bus.settings_changed.emit()

        QMessageBox.information(
            self,
            "Ground-station Settings Updated",
            f"Telemetry UDP Port: {udp_port}\n"
            f"HDMI Capture Device: {settings.video_device_name or 'not selected'}\n\n"
            "Runtime listeners have been updated. These values are not persisted; set "
            "RESQ_TELEMETRY_UDP_PORT, RESQ_VIDEO_DEVICE_NAME, and "
            "RESQ_ENABLE_MOCK_SIMULATOR in the environment to retain them after restart."
        )
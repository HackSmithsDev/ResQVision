from PySide6.QtTest import QSignalSpy
from PySide6.QtWidgets import QMessageBox

from resq_command.core.config import settings
from resq_command.core.events import EventBus
from resq_command.pages.command.system_config import SystemConfigPage


def test_applying_ground_station_settings_emits_change(qapp, monkeypatch) -> None:
    monkeypatch.setattr(settings, "telemetry_udp_port", 14550)
    monkeypatch.setattr(settings, "video_device_name", None)
    monkeypatch.setattr(settings, "enable_mock_simulator", False)
    monkeypatch.setattr(QMessageBox, "information", staticmethod(lambda *_: None))

    event_bus = EventBus()
    settings_changed = QSignalSpy(event_bus.settings_changed)
    page = SystemConfigPage(event_bus)
    page.udp_input.setText("14551")
    page.video_device_input.setText("HDMI capture")
    page.sim_combo.setCurrentIndex(0)
    page._save_config()

    assert settings.telemetry_udp_port == 14551
    assert settings.video_device_name == "HDMI capture"
    assert settings.enable_mock_simulator
    assert settings_changed.count() == 1
    page.close()
    page.deleteLater()


def test_invalid_port_does_not_apply_settings(qapp, monkeypatch) -> None:
    monkeypatch.setattr(settings, "telemetry_udp_port", 14550)
    monkeypatch.setattr(QMessageBox, "warning", staticmethod(lambda *_: None))

    event_bus = EventBus()
    settings_changed = QSignalSpy(event_bus.settings_changed)
    page = SystemConfigPage(event_bus)
    page.udp_input.setText("65536")

    page._save_config()

    assert settings.telemetry_udp_port == 14550
    assert settings_changed.count() == 0
    page.close()
    page.deleteLater()

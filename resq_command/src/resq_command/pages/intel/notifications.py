"""
Sub-page 06: Priority Notifications & Event Audit Log.
Integrated with dynamic QSS variants, EventBus alert streams, and NotificationAlert models.
"""

from datetime import datetime
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame, QPushButton, QScrollArea
from resq_command.ui.widgets.status_badge import StatusBadge
from resq_command.db.models import NotificationAlert


class NotificationsPage(QWidget):
    """Real-Time Event Alerts & Notification Audit Stream."""

    def __init__(self, event_bus, parent=None):
        super().__init__(parent)
        self.event_bus = event_bus

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(14)

        header = QHBoxLayout()
        title = QLabel("PRIORITY NOTIFICATION QUEUE & EVENT LOGS")
        title.setProperty("variant", "header")
        header.addWidget(title)
        header.addStretch()

        clear_btn = QPushButton("ACKNOWLEDGE ALL")
        clear_btn.clicked.connect(self._clear_all_notifications)
        header.addWidget(clear_btn)
        root.addLayout(header)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)

        self.container = QWidget()
        self.scroll_lay = QVBoxLayout(self.container)
        self.scroll_lay.setSpacing(10)

        seed_alerts = [
            NotificationAlert(
                alert_id="ALT-001",
                severity="CRITICAL",
                title="UAV-03 BATTERY CRITICAL: 18%",
                description="Auto-initiating Return-To-Launch (RTL) protocol.",
                timestamp="13:08:12",
            ),
            NotificationAlert(
                alert_id="ALT-002",
                severity="ALERT",
                title="H2S GAS SPIKE DETECTED",
                description="Sensor Pod B-02 reading 4.8 PPM near evacuation route.",
                timestamp="13:06:45",
            ),
            NotificationAlert(
                alert_id="ALT-003",
                severity="INFO",
                title="TEAM BRAVO ARRIVED AT TARGET",
                description="Search Sector Bravo grid search initiated.",
                timestamp="12:59:10",
            ),
            NotificationAlert(
                alert_id="ALT-004",
                severity="INFO",
                title="COMMS REPEATER NODE-03 ACTIVE",
                description="LoRa mesh link established over perimeter ridge.",
                timestamp="12:50:02",
            ),
        ]

        for alert in seed_alerts:
            self._render_alert_card(alert)

        self.scroll_lay.addStretch()
        scroll.setWidget(self.container)
        root.addWidget(scroll)

        if self.event_bus:
            self.event_bus.alert_triggered.connect(self._on_live_alert)

    def _render_alert_card(self, alert: NotificationAlert):
        variant_map = {
            "CRITICAL": ("card-critical", "CRITICAL"),
            "ALERT": ("card-warning", "WARNING"),
            "INFO": ("card-nominal", "NOMINAL"),
        }
        card_var, badge_lvl = variant_map.get(alert.severity.upper(), ("card", "MUTED"))

        card = QFrame()
        card.setProperty("variant", card_var)
        c_lay = QVBoxLayout(card)
        c_lay.setSpacing(4)

        top = QHBoxLayout()
        badge = StatusBadge(alert.severity, badge_lvl)
        top.addWidget(badge)

        title_lbl = QLabel(f"<b>{alert.title}</b>")
        top.addWidget(title_lbl)
        top.addStretch()

        ts_lbl = QLabel(alert.timestamp)
        ts_lbl.setProperty("variant", "meta")
        top.addWidget(ts_lbl)
        c_lay.addLayout(top)

        desc_lbl = QLabel(alert.description)
        c_lay.addWidget(desc_lbl)

        # Insert above stretch spacer
        self.scroll_lay.insertWidget(self.scroll_lay.count() - 1, card)

    def _on_live_alert(self, alert_dict: dict):
        alert = NotificationAlert(
            alert_id=f"ALT-{datetime.now().strftime('%M%S')}",
            severity=alert_dict.get("severity", "ALERT"),
            title=alert_dict.get("title", "SYSTEM ALERT"),
            description=alert_dict.get("desc", ""),
            timestamp=alert_dict.get("timestamp", datetime.now().strftime("%H:%M:%S")),
        )
        self._render_alert_card(alert)

    def _clear_all_notifications(self):
        while self.scroll_lay.count() > 1:
            item = self.scroll_lay.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
        if self.event_bus:
            self.event_bus.alert_count_changed.emit(0)
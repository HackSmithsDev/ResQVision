"""Backend-backed collection view shared by Command operational pages."""

from typing import Any, Optional
from uuid import uuid4

from PySide6.QtCore import QThread, Signal, Qt
from PySide6.QtWidgets import (
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QScrollArea,
    QVBoxLayout,
    QWidget,
)

from resq_command.api.client import ResQVisionAPIClient

_api_client = ResQVisionAPIClient()


class _RequestWorker(QThread):
    completed = Signal(object)
    failed = Signal(str)

    def __init__(
        self,
        operation: str,
        collection: str,
        email: str = "",
        password: str = "",
        parent: Optional[QWidget] = None,
    ):
        super().__init__(parent)
        self.operation = operation
        self.collection = collection
        self.email = email
        self.password = password

    def run(self) -> None:
        try:
            if self.operation == "login":
                result = _api_client.login(
                    email=self.email,
                    password=self.password,
                    device_id=f"resq-command-{uuid4()}",
                    device_info="ResQ Command",
                )
            else:
                result = _api_client.list_workspace_records(self.collection)
            self.completed.emit(result)
        except Exception as exc:
            self.failed.emit(str(exc))


class WorkspaceRecordsPage(QWidget):
    """Load authenticated, owner-scoped records without inventing demo data."""

    def __init__(
        self,
        collection: str,
        title: str,
        parent: Optional[QWidget] = None,
    ):
        super().__init__(parent)
        self.collection = collection
        self._worker: Optional[_RequestWorker] = None
        self._load_after_login = False

        root = QVBoxLayout(self)
        root.setContentsMargins(20, 20, 20, 20)
        root.setSpacing(12)

        heading = QLabel(title)
        heading.setProperty("variant", "header")
        root.addWidget(heading)

        self.login_panel = QWidget(self)
        login_layout = QFormLayout(self.login_panel)
        self.email_input = QLineEdit()
        self.email_input.setPlaceholderText("Account email")
        self.password_input = QLineEdit()
        self.password_input.setObjectName("passwordInput")
        self.password_input.setPlaceholderText("Account password")
        self.password_input.setEchoMode(QLineEdit.Password)
        self.login_button = QPushButton("SIGN IN")
        self.login_button.clicked.connect(self._login)
        login_layout.addRow("Email", self.email_input)
        login_layout.addRow("Password", self.password_input)
        login_layout.addRow(self.login_button)
        root.addWidget(self.login_panel)

        actions = QHBoxLayout()
        self.session_label = QLabel()
        actions.addWidget(self.session_label)
        actions.addStretch()
        self.refresh_button = QPushButton("REFRESH")
        self.refresh_button.clicked.connect(self._load)
        self.sign_out_button = QPushButton("SIGN OUT")
        self.sign_out_button.clicked.connect(self._sign_out)
        actions.addWidget(self.refresh_button)
        actions.addWidget(self.sign_out_button)
        root.addLayout(actions)

        self.state_label = QLabel()
        self.state_label.setWordWrap(True)
        root.addWidget(self.state_label)

        self.scroll = QScrollArea(self)
        self.scroll.setWidgetResizable(True)
        self.records_container = QWidget(self.scroll)
        self.records_layout = QVBoxLayout(self.records_container)
        self.records_layout.addStretch()
        self.scroll.setWidget(self.records_container)
        root.addWidget(self.scroll, stretch=1)
        self._update_session_controls()
        if _api_client.headers.get("Authorization"):
            self._load()
        else:
            self.state_label.setText("Sign in to load records from the backend.")

    def _login(self) -> None:
        if not self.email_input.text().strip() or not self.password_input.text():
            self.state_label.setText("Enter your account email and password.")
            return
        self._start_request(
            _RequestWorker(
                "login",
                self.collection,
                self.email_input.text().strip(),
                self.password_input.text(),
                self,
            ),
            "Signing in…",
        )

    def _load(self) -> None:
        self._update_session_controls()
        if not _api_client.headers.get("Authorization"):
            self.state_label.setText("Sign in to load records from the backend.")
            return
        self._start_request(
            _RequestWorker("list", self.collection, parent=self),
            "Loading backend records…",
        )

    def _start_request(self, worker: _RequestWorker, message: str) -> None:
        if self._worker is not None and self._worker.isRunning():
            return
        self._worker = worker
        self.state_label.setText(message)
        self.refresh_button.setEnabled(False)
        self.login_button.setEnabled(False)
        worker.completed.connect(self._request_completed)
        worker.failed.connect(self._request_failed)
        worker.finished.connect(self._request_finished)
        worker.start()

    def _request_completed(self, result: Any) -> None:
        if isinstance(result, dict) and isinstance(result.get("access_token"), str):
            self.password_input.clear()
            self._update_session_controls()
            self._load_after_login = True
            return
        self._render_records(result)

    def _request_failed(self, message: str) -> None:
        self.state_label.setText(f"Backend request failed: {message}")

    def _request_finished(self) -> None:
        operation = self._worker.operation if self._worker is not None else None
        self.refresh_button.setEnabled(True)
        self.login_button.setEnabled(True)
        self._worker = None
        if operation == "login" and self._load_after_login:
            self._load_after_login = False
            self._load()

    def _render_records(self, records: Any) -> None:
        while self.records_layout.count() > 1:
            item = self.records_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
        if not records:
            self.state_label.setText("No records are available for this account.")
            return
        self.state_label.setText(f"{len(records)} backend record(s).")
        for record in records:
            data = record["data"]
            lines = [
                f"{key.replace('_', ' ').title()}: {value}"
                for key, value in data.items()
                if value is not None and isinstance(value, (str, int, float, bool))
            ]
            title = next(
                (
                    str(data[key])
                    for key in ("title", "name", "callsign")
                    if data.get(key) is not None
                ),
                str(record.get("id", "Record")),
            )
            card = QLabel("\n".join((title, *lines)))
            card.setWordWrap(True)
            card.setTextFormat(Qt.TextFormat.PlainText)
            card.setProperty("variant", "card")
            self.records_layout.insertWidget(self.records_layout.count() - 1, card)

    def _sign_out(self) -> None:
        _api_client.set_token("")
        self._update_session_controls()
        self._render_records([])
        self.state_label.setText("Signed out. Sign in to load backend records.")

    def _update_session_controls(self) -> None:
        signed_in = bool(_api_client.headers.get("Authorization"))
        self.login_panel.setVisible(not signed_in)
        self.sign_out_button.setVisible(signed_in)
        self.session_label.setText(
            "Backend account connected" if signed_in else "Backend account not connected"
        )

"""Backend-backed collection view shared by Command operational pages."""

import json
from typing import Any, Optional
from uuid import uuid4

from PySide6.QtCore import QThread, Signal, Qt
from PySide6.QtWidgets import (
    QFormLayout,
    QHBoxLayout,
    QInputDialog,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
    QPlainTextEdit,
    QPushButton,
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
        record_id: str = "",
        data: Optional[dict[str, Any]] = None,
        parent: Optional[QWidget] = None,
    ):
        super().__init__(parent)
        self.operation = operation
        self.collection = collection
        self.email = email
        self.password = password
        self.record_id = record_id
        self.data = data or {}

    def run(self) -> None:
        try:
            if self.operation == "login":
                result = _api_client.login(
                    email=self.email,
                    password=self.password,
                    device_id=f"resq-command-{uuid4()}",
                    device_info="ResQ Command",
                )
            elif self.operation == "create":
                result = _api_client.create_workspace_record(self.collection, self.data)
            elif self.operation == "update":
                result = _api_client.update_workspace_record(
                    self.collection,
                    self.record_id,
                    self.data,
                )
            elif self.operation == "delete":
                _api_client.delete_workspace_record(self.collection, self.record_id)
                result = None
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
        self._reload_after_request = False

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

        record_actions = QHBoxLayout()
        self.create_button = QPushButton("NEW RECORD")
        self.create_button.clicked.connect(self._create_record)
        self.edit_button = QPushButton("EDIT")
        self.edit_button.clicked.connect(self._edit_record)
        self.delete_button = QPushButton("DELETE")
        self.delete_button.clicked.connect(self._delete_record)
        record_actions.addWidget(self.create_button)
        record_actions.addWidget(self.edit_button)
        record_actions.addWidget(self.delete_button)
        record_actions.addStretch()
        root.addLayout(record_actions)

        self.records_list = QListWidget(self)
        self.records_list.currentItemChanged.connect(self._show_record)
        self.record_details = QPlainTextEdit(self)
        self.record_details.setReadOnly(True)
        root.addWidget(self.records_list, stretch=1)
        root.addWidget(self.record_details, stretch=1)
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

    def _create_record(self) -> None:
        self._edit_record_data("create", "{}")

    def _edit_record(self) -> None:
        item = self.records_list.currentItem()
        if item is None:
            return
        record = item.data(Qt.ItemDataRole.UserRole)
        self._edit_record_data("update", json.dumps(record["data"], indent=2), record["id"])

    def _edit_record_data(
        self,
        operation: str,
        initial_value: str,
        record_id: str = "",
    ) -> None:
        value, accepted = QInputDialog.getMultiLineText(
            self,
            "Workspace record",
            "Record data (JSON object)",
            initial_value,
        )
        if not accepted:
            return
        try:
            data = json.loads(value)
        except json.JSONDecodeError as exc:
            self.state_label.setText(f"Invalid JSON: {exc.msg}")
            return
        if not isinstance(data, dict):
            self.state_label.setText("Record data must be a JSON object.")
            return
        self._reload_after_request = True
        self._start_request(
            _RequestWorker(
                operation,
                self.collection,
                record_id=record_id,
                data=data,
                parent=self,
            ),
            "Saving workspace record…",
        )

    def _delete_record(self) -> None:
        item = self.records_list.currentItem()
        if item is None:
            return
        record = item.data(Qt.ItemDataRole.UserRole)
        answer = QMessageBox.question(
            self,
            "Delete record",
            f"Delete backend record {record['id']}?",
        )
        if answer != QMessageBox.StandardButton.Yes:
            return
        self._reload_after_request = True
        self._start_request(
            _RequestWorker(
                "delete",
                self.collection,
                record_id=record["id"],
                parent=self,
            ),
            "Deleting workspace record…",
        )

    def _start_request(self, worker: _RequestWorker, message: str) -> None:
        if self._worker is not None and self._worker.isRunning():
            return
        self._worker = worker
        self.state_label.setText(message)
        self.refresh_button.setEnabled(False)
        self.login_button.setEnabled(False)
        self.create_button.setEnabled(False)
        self.edit_button.setEnabled(False)
        self.delete_button.setEnabled(False)
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
        operation = self._worker.operation if self._worker is not None else None
        if operation in {"create", "update", "delete"}:
            self.state_label.setText("Workspace record saved to the backend.")
            return
        self._render_records(result)

    def _request_failed(self, message: str) -> None:
        self.state_label.setText(f"Backend request failed: {message}")

    def _request_finished(self) -> None:
        operation = self._worker.operation if self._worker is not None else None
        self.refresh_button.setEnabled(True)
        self.login_button.setEnabled(True)
        self.create_button.setEnabled(True)
        self.edit_button.setEnabled(self.records_list.currentItem() is not None)
        self.delete_button.setEnabled(self.records_list.currentItem() is not None)
        self._worker = None
        if operation == "login" and self._load_after_login:
            self._load_after_login = False
            self._load()
        elif operation in {"create", "update", "delete"} and self._reload_after_request:
            self._reload_after_request = False
            self._load()

    def _render_records(self, records: Any) -> None:
        self.records_list.clear()
        self.record_details.clear()
        if not records:
            self.state_label.setText("No records are available for this account.")
            return
        self.state_label.setText(f"{len(records)} backend record(s).")
        for record in records:
            item = QListWidgetItem(str(record.get("id", "Record")))
            item.setData(Qt.ItemDataRole.UserRole, record)
            self.records_list.addItem(item)
        self.edit_button.setEnabled(False)
        self.delete_button.setEnabled(False)

    def _show_record(self, current: Optional[QListWidgetItem], previous: Optional[QListWidgetItem]) -> None:
        del previous
        record = current.data(Qt.ItemDataRole.UserRole) if current is not None else None
        self.record_details.setPlainText(
            json.dumps(record.get("data", {}), indent=2) if record else ""
        )
        self.edit_button.setEnabled(record is not None)
        self.delete_button.setEnabled(record is not None)

    def _sign_out(self) -> None:
        _api_client.set_token("")
        self._update_session_controls()
        self._render_records([])
        self.state_label.setText("Signed out. Sign in to load backend records.")

    def _update_session_controls(self) -> None:
        signed_in = bool(_api_client.headers.get("Authorization"))
        self.login_panel.setVisible(not signed_in)
        self.sign_out_button.setVisible(signed_in)
        self.create_button.setVisible(signed_in)
        self.edit_button.setVisible(signed_in)
        self.delete_button.setVisible(signed_in)
        self.session_label.setText(
            "Backend account connected" if signed_in else "Backend account not connected"
        )

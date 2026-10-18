from PySide6.QtWidgets import QLabel, QLineEdit

from resq_command.api.routes import APIRoutes
from resq_command.pages.workspace_records import WorkspaceRecordsPage


def test_workspace_page_prompts_sign_in_without_sample_records(qapp) -> None:
    page = WorkspaceRecordsPage("drones", "Fleet records")

    assert page.state_label.text() == "Sign in to load records from the backend."
    assert not page.login_panel.isHidden()
    assert "Drone A" not in page.findChild(QLabel).text()
    assert APIRoutes.workspace_collection("environmental-readings") == (
        "/workspace/environmental-readings"
    )
    page.close()
    page.deleteLater()


def test_workspace_page_has_password_input(qapp) -> None:
    page = WorkspaceRecordsPage("missions", "Mission records")

    password_input = page.findChild(QLineEdit, "passwordInput")
    assert password_input is page.password_input
    assert password_input.echoMode() == QLineEdit.EchoMode.Password
    page.close()
    page.deleteLater()


def test_workspace_page_renders_backend_record_payload(qapp) -> None:
    page = WorkspaceRecordsPage("drones", "Fleet records")
    page._render_records(
        [
            {
                "id": "backend-record-7",
                "data": {"callsign": "Field unit 7", "battery": 81},
            }
        ]
    )

    assert page.records_list.count() == 1
    assert page.records_list.item(0).text() == "backend-record-7"
    page.records_list.setCurrentRow(0)
    assert '"callsign": "Field unit 7"' in page.record_details.toPlainText()
    assert page.edit_button.isEnabled()
    page.close()
    page.deleteLater()

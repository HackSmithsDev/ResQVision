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

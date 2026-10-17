from resq_command.pages.workspace_records import WorkspaceRecordsPage


class EnvironmentPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("environmental-readings", "Environmental readings", parent)

from resq_command.pages.workspace_records import WorkspaceRecordsPage


class IncidentRisksPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("incidents", "Incident records", parent)

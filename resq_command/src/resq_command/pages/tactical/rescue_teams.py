from resq_command.pages.workspace_records import WorkspaceRecordsPage


class RescueTeamsPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("teams", "Rescue team records", parent)

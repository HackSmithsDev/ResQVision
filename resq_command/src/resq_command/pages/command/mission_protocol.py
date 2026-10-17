from resq_command.pages.workspace_records import WorkspaceRecordsPage


class MissionProtocolPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("missions", "Mission records", parent)

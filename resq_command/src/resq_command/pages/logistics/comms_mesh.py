from resq_command.pages.workspace_records import WorkspaceRecordsPage


class CommsMeshPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("messages", "Communications records", parent)

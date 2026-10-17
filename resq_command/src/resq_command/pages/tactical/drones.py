from resq_command.pages.workspace_records import WorkspaceRecordsPage


class DronesPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("drones", "Fleet records", parent)

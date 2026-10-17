from resq_command.pages.workspace_records import WorkspaceRecordsPage


class NotificationsPage(WorkspaceRecordsPage):
    def __init__(self, event_bus=None, parent=None):
        super().__init__("notifications", "Notification records", parent)

from PySide6.QtWidgets import QApplication
from resq_command.style.qss_loader import QSSLoader
from resq_command.style.palette import TacticalPalette

class ThemeManager:
    """Manages application-wide QSS theme injection and palette synchronization."""

    @classmethod
    def apply_theme(cls, app: QApplication):
        """Loads all compiled QSS templates and applies them globally to the QApplication."""
        compiled_qss = QSSLoader.load_stylesheet()
        app.setStyleSheet(compiled_qss)

    @classmethod
    def reload_theme(cls, app: QApplication):
        """Hot-reloads the QSS at runtime without restarting the process."""
        cls.apply_theme(app)
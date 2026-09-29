"""
ResQVision Command - Base Page & Category Shell Architecture
Provides standardized lifecycle hooks, event bus binding, and memory cleanup.
"""

from typing import Optional
from PySide6.QtWidgets import QWidget, QVBoxLayout
from resq_command.core.events import EventBus


class BasePage(QWidget):
    """
    Abstract base class for all 11 tactical sub-pages.
    Enforces standardized initialization, signal binding, and activation lifecycles.
    """

    PAGE_ID: str = "base_page"

    def __init__(self, event_bus: Optional[EventBus] = None, parent: Optional[QWidget] = None):
        super().__init__(parent)
        self.event_bus = event_bus
        self.is_active: bool = False

        self.setup_ui()
        if self.event_bus:
            self.bind_events()

    def setup_ui(self) -> None:
        """Construct layouts, child widgets, and properties. Override in subclasses."""
        pass

    def bind_events(self) -> None:
        """Connect EventBus signals to local handler methods. Override in subclasses."""
        pass

    def on_activated(self) -> None:
        """
        Triggered when this sub-page becomes the visible page in QStackedWidget.
        Use this to resume animation timers, start polling, or request fresh data.
        """
        self.is_active = True

    def on_deactivated(self) -> None:
        """
        Triggered when the user switches away from this page.
        Use this to pause heavy video decoders, canvas timers, or cancel in-flight REST calls.
        """
        self.is_active = False


class BaseCategoryShell(QWidget):
    """
    Abstract base class for the 4 top-level category shells
    (Tactical, Intel, Logistics, Command).
    Manages the child SubNavBar and QStackedWidget page transitions.
    """

    CATEGORY_ID: str = "base_category"

    def __init__(self, event_bus: Optional[EventBus] = None, parent: Optional[QWidget] = None):
        super().__init__(parent)
        self.event_bus = event_bus

        self.root_layout = QVBoxLayout(self)
        self.root_layout.setContentsMargins(0, 0, 0, 0)
        self.root_layout.setSpacing(0)

        self.setup_shell()

    def setup_shell(self) -> None:
        """Initialize SubNavBar, child pages, and wire QStackedWidget. Override in subclasses."""
        pass

    def switch_sub_page(self, index: int) -> None:
        """Standardized handler for SubNavBar clicks."""
        if hasattr(self, "stack") and self.stack:
            prev_widget = self.stack.currentWidget()
            if isinstance(prev_widget, BasePage):
                prev_widget.on_deactivated()

            self.stack.setCurrentIndex(index)

            curr_widget = self.stack.currentWidget()
            if isinstance(curr_widget, BasePage):
                curr_widget.on_activated()
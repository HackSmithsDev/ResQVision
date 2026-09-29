# src/resq_command/ui/panels/sub_nav_bar.py
from typing import List, Tuple
from PySide6.QtWidgets import QFrame, QHBoxLayout, QPushButton, QButtonGroup
from PySide6.QtCore import Signal
from resq_command.style.palette import TacticalPalette

class SubNavBar(QFrame):
    """Segmented horizontal tab selector for category sub-pages."""
    sub_page_changed = Signal(int)

    def __init__(self, tabs: List[Tuple[str, int]], parent=None):
        super().__init__(parent)
        self.setFixedHeight(48)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {TacticalPalette.BG_PANEL};
                border-bottom: 1px solid {TacticalPalette.SURFACE_BORDER};
            }}
            QPushButton {{
                background: transparent;
                border: none;
                color: {TacticalPalette.TEXT_MUTED};
                padding: 10px 18px;
                font-size: 12px;
                font-weight: 700;
                border-bottom: 2px solid transparent;
            }}
            QPushButton:hover:!checked {{
                color: {TacticalPalette.INDIGO_PRIMARY};
            }}
            QPushButton:checked {{
                color: {TacticalPalette.INDIGO_ACCENT};
                border-bottom: 2px solid {TacticalPalette.INDIGO_ACCENT};
            }}
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 0, 16, 0)
        layout.setSpacing(8)

        self.btn_group = QButtonGroup(self)
        self.btn_group.setExclusive(True)

        for label, idx in tabs:
            btn = QPushButton(label)
            btn.setCheckable(True)
            if idx == 0:
                btn.setChecked(True)
            btn.clicked.connect(lambda _, i=idx: self.sub_page_changed.emit(i))
            self.btn_group.addButton(btn, idx)
            layout.addWidget(btn)

        layout.addStretch()
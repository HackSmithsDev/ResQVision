# src/resq_command/ui/panels/nav_rail.py
from PySide6.QtWidgets import QFrame, QVBoxLayout, QPushButton, QButtonGroup
from PySide6.QtCore import Signal
from resq_command.style.palette import TacticalPalette

class NavRail(QFrame):
    category_selected = Signal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedWidth(88)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {TacticalPalette.BG_PANEL};
                border-right: 1px solid {TacticalPalette.SURFACE_BORDER};
            }}
            QPushButton {{
                background: transparent;
                border: none;
                color: {TacticalPalette.TEXT_MUTED};
                padding: 18px 0px;
                font-size: 11px;
                font-weight: 700;
                letter-spacing: 0.8px;
            }}
            QPushButton:hover:!checked {{
                color: {TacticalPalette.INDIGO_PRIMARY};
                background-color: {TacticalPalette.BG_WINDOW};
            }}
            QPushButton:checked {{
                color: {TacticalPalette.INDIGO_ACCENT};
                border-left: 3px solid {TacticalPalette.INDIGO_ACCENT};
                background-color: {TacticalPalette.VIOLET_LIGHT};
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 12, 0, 12)
        layout.setSpacing(6)

        self.btn_group = QButtonGroup(self)
        self.btn_group.setExclusive(True)

        categories = [
            ("TACTICAL", 0),
            ("INTEL", 1),
            ("LOGISTICS", 2),
            ("COMMAND", 3),
        ]

        for label, idx in categories:
            btn = QPushButton(label)
            btn.setCheckable(True)
            if idx == 0:
                btn.setChecked(True)
            btn.clicked.connect(lambda _, i=idx: self.category_selected.emit(i))
            self.btn_group.addButton(btn, idx)
            layout.addWidget(btn)

        layout.addStretch()
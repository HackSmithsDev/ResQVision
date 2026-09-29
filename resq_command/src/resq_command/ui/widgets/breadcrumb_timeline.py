from PySide6.QtWidgets import QWidget, QHBoxLayout, QLabel
from resq_command.style.palette import TacticalPalette

class BreadcrumbTimeline(QWidget):
    """Visual chronological step progression bar."""

    def __init__(self, stages: list[str], current_idx: int = 0, parent=None):
        super().__init__(parent)
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        for i, stage in enumerate(stages):
            is_active = i == current_idx
            is_done = i < current_idx

            color = TacticalPalette.INDIGO_ACCENT if is_active else (TacticalPalette.LEVEL_GREEN if is_done else TacticalPalette.TEXT_MUTED)
            lbl = QLabel(f"<b>{i+1}. {stage}</b>")
            lbl.setStyleSheet(f"color: {color}; font-size: 11px;")
            layout.addWidget(lbl)

            if i < len(stages) - 1:
                sep = QLabel("→")
                sep.setStyleSheet(f"color: {TacticalPalette.TEXT_MUTED};")
                layout.addWidget(sep)

        layout.addStretch()
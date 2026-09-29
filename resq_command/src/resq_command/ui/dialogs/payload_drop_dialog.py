from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton
from resq_command.style.palette import TacticalPalette

class PayloadDropDialog(QDialog):
    """Confirms target coordinate clearance before releasing cargo/first-aid pod."""

    def __init__(self, target_coords: tuple[float, float], parent=None):
        super().__init__(parent)
        self.setWindowTitle("CONFIRM PAYLOAD DEPLOYMENT")
        self.setFixedSize(380, 180)
        self.setStyleSheet(f"background-color: {TacticalPalette.BG_PANEL};")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(12)

        title = QLabel("RELEASE FIRST-AID / CARGO PAYLOAD?")
        title.setStyleSheet(f"color: {TacticalPalette.INDIGO_PRIMARY}; font-size: 14px; font-weight: 800;")
        layout.addWidget(title)

        coords_lbl = QLabel(f"Target Coordinates: <b>{target_coords[0]:.5f}, {target_coords[1]:.5f}</b>")
        coords_lbl.setStyleSheet(f"color: {TacticalPalette.TEXT_PRIMARY}; font-size: 12px;")
        layout.addWidget(coords_lbl)

        btn_box = QHBoxLayout()
        cancel = QPushButton("CANCEL")
        cancel.clicked.connect(self.reject)
        btn_box.addWidget(cancel)

        drop = QPushButton("EXECUTE DROP")
        drop.setStyleSheet(f"background-color: {TacticalPalette.INDIGO_ACCENT}; color: #FFFFFF; font-weight: 700;")
        drop.clicked.connect(self.accept)
        btn_box.addWidget(drop)

        layout.addLayout(btn_box)
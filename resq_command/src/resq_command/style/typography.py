from PySide6.QtGui import QFont, QFontDatabase

class Typography:
    """Central typography scale for authoritative government command displays."""

    FONT_FAMILY = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif'
    MONO_FAMILY = '"JetBrains Mono", "SF Mono", "Fira Code", Consolas, monospace'

    @classmethod
    def get_font(cls, size: int = 12, weight: QFont.Weight = QFont.Weight.Normal, mono: bool = False) -> QFont:
        family = cls.MONO_FAMILY if mono else cls.FONT_FAMILY
        font = QFont()
        font.setFamily(family)
        font.setPixelSize(size)
        font.setWeight(weight)
        return font
from pathlib import Path
from resq_command.style.palette import TacticalPalette

class QSSLoader:
    """Compiles modular QSS stylesheets and injects TacticalPalette tokens."""

    STYLESHEETS_DIR = Path(__file__).resolve().parent / "stylesheets"

    @classmethod
    def load_stylesheet(cls) -> str:
        compiled_qss = []

        # Order matters: base resets first, then inputs/buttons, cards, and tables
        files = ["base.qss", "buttons.qss", "inputs.qss", "cards.qss", "tables.qss"]

        for filename in files:
            path = cls.STYLESHEETS_DIR / filename
            if path.exists():
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                    content = cls._inject_tokens(content)
                    compiled_qss.append(content)

        return "\n\n".join(compiled_qss)

    @classmethod
    def _inject_tokens(cls, qss: str) -> str:
        # Introspect all uppercase token attributes from TacticalPalette
        tokens = {
            k: getattr(TacticalPalette, k)
            for k in dir(TacticalPalette)
            if k.isupper() and isinstance(getattr(TacticalPalette, k), str)
        }

        for key, val in tokens.items():
            qss = qss.replace(f"{{{{{key}}}}}", val)

        return qss
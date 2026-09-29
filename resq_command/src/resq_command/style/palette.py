# src/resq_command/style/palette.py

class TacticalPalette:
    # --- Light Window & Surface Foundation ---
    BG_WINDOW = "#F4F6FA"          # Clean institutional off-white / light slate
    BG_PANEL = "#FFFFFF"           # Pure white for elevation cards & navigation
    BG_CARD = "#EEF2F8"            # Recessed background for badges & metric chips
    SURFACE_BORDER = "#D6DFEB"     # Crisp divider stroke
    SURFACE_BORDER_LIGHT = "#E8EEF5"

    # --- Brand & Hierarchy: Indigo / Electric Violet ---
    INDIGO_PRIMARY = "#312E81"     # Deep authoritative navy indigo (Headers, active items)
    INDIGO_ACCENT = "#4F46E5"      # Bright electric indigo (Focus rings, primary actions)
    VIOLET_GLOW = "#7C3AED"        # Vivid violet (Jarvis AI Core / Siri Orb gradient)
    VIOLET_LIGHT = "#EDE9FE"       # Light violet badge tint

    # --- Universal Safety Levels (Red / Yellow / Green) ---
    LEVEL_RED = "#DC2626"          # Critical / SOS / Geofence Breach
    LEVEL_RED_BG = "#FEE2E2"       # Soft red pill background
    
    LEVEL_YELLOW = "#D97706"       # Alert / Caution / Low Battery / High Heat
    LEVEL_YELLOW_BG = "#FEF3C7"    # Soft yellow pill background
    
    LEVEL_GREEN = "#16A34A"        # Nominal / Secure / Armed / Online
    LEVEL_GREEN_BG = "#DCFCE7"     # Soft green pill background

    # --- Typography (Light Mode Contrast) ---
    TEXT_PRIMARY = "#0F172A"       # High-contrast slate 900
    TEXT_SECONDARY = "#334155"     # Slate 700 for subtitles and table headers
    TEXT_MUTED = "#64748B"         # Slate 500 for secondary metrics & timestamps

    @classmethod
    def get_base_qss(cls) -> str:
        return f"""
        QMainWindow, QWidget {{
            background-color: {cls.BG_WINDOW};
            color: {cls.TEXT_PRIMARY};
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            font-size: 13px;
        }}
        QFrame {{
            border: none;
        }}
        QScrollBar:vertical {{
            background: {cls.BG_WINDOW};
            width: 8px;
            margin: 0;
        }}
        QScrollBar::handle:vertical {{
            background: {cls.SURFACE_BORDER};
            min-height: 24px;
            border-radius: 4px;
        }}
        QScrollBar::handle:vertical:hover {{
            background: {cls.INDIGO_ACCENT};
        }}
        """
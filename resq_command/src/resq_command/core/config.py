"""
ResQVision Command - Runtime Configuration Engine
Handles environment overrides, filesystem paths, and persistent workstation settings.
"""

from pathlib import Path
from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class AppConfig(BaseSettings):
    """Configuration schema with environment variable fallback support."""

    model_config = SettingsConfigDict(
        env_prefix="RESQ_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    # Runtime Environment
    env: str = Field(default="development", description="development | staging | production")
    debug_mode: bool = Field(default=True, description="Enable verbose telemetry and UI debug logs")

    # Local Directory Roots
    base_dir: Path = Field(default_factory=lambda: Path(__file__).resolve().parent.parent.parent.parent)
    logs_dir: Path = Field(default_factory=lambda: Path.home() / ".resq_command" / "logs")
    cache_dir: Path = Field(default_factory=lambda: Path.home() / ".resq_command" / "cache")

    # Hardware & Telemetry Bindings
    lora_serial_port: str = Field(default="/dev/cu.usbserial-110")
    mavlink_udp_port: int = Field(default=14550)
    enable_mock_simulator: bool = Field(default=True)

    # Window State & Geometry Defaults
    window_width: int = Field(default=1440)
    window_height: int = Field(default=900)
    window_maximized: bool = Field(default=False)

    def initialize_filesystem(self) -> None:
        """Create required runtime folders if they do not exist."""
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        self.cache_dir.mkdir(parents=True, exist_ok=True)


# Global singleton instance for application-wide access
settings = AppConfig()
settings.initialize_filesystem()
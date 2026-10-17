"""Paths for existing shared ResQVision backend APIs."""

from typing import Final
from urllib.parse import quote


class APIRoutes:
    LOGIN: Final[str] = "/auth/login"
    CURRENT_USER: Final[str] = "/users/me"
    TELEMETRY_RECEIVE: Final[str] = "/telemetry/receive"
    TELEMETRY_LATEST: Final[str] = "/telemetry/latest"

    @classmethod
    def latest_telemetry(cls, drone_id: str | None = None) -> str:
        if drone_id is None:
            return cls.TELEMETRY_LATEST
        return f"{cls.TELEMETRY_LATEST}/{quote(drone_id, safe='')}"

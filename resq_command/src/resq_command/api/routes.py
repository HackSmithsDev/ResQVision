"""Paths for existing shared ResQVision backend APIs."""

from typing import Final
from urllib.parse import quote


class APIRoutes:
    LOGIN: Final[str] = "/auth/login"
    CURRENT_USER: Final[str] = "/users/me"
    TELEMETRY_RECEIVE: Final[str] = "/telemetry/receive"
    TELEMETRY_LATEST: Final[str] = "/telemetry/latest"
    TELEMETRY_SIMULATED: Final[str] = "/telemetry/simulated"

    @classmethod
    def workspace_collection(cls, collection: str) -> str:
        return f"/workspace/{quote(collection, safe='')}"

    @classmethod
    def workspace_record(cls, collection: str, record_id: str) -> str:
        return f"{cls.workspace_collection(collection)}/{quote(record_id, safe='')}"

    @classmethod
    def latest_telemetry(cls, drone_id: str | None = None) -> str:
        if drone_id is None:
            return cls.TELEMETRY_LATEST
        return f"{cls.TELEMETRY_LATEST}/{quote(drone_id, safe='')}"

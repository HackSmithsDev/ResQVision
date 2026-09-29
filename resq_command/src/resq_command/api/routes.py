"""
ResQVision Command - API Route Endpoints
Centralized URL routes for REST APIs and WebSocket streams.
"""

from typing import Final


class APIRoutes:
    # Auth & Station
    LOGIN: Final[str] = "/api/v1/auth/login"
    STATION_SYNC: Final[str] = "/api/v1/station/sync"

    # Tactical & Fleet
    DRONES: Final[str] = "/api/v1/tactical/drones"
    TEAMS: Final[str] = "/api/v1/tactical/teams"
    DISPATCH_ORDER: Final[str] = "/api/v1/tactical/dispatch"

    # Intel & Feeds
    SOURCES: Final[str] = "/api/v1/intel/sources"
    NOTIFICATIONS: Final[str] = "/api/v1/intel/notifications"
    ACK_NOTIFICATION: Final[str] = "/api/v1/intel/notifications/{id}/ack"

    # Command & Logistics
    INCIDENTS: Final[str] = "/api/v1/command/incidents"
    INVENTORY: Final[str] = "/api/v1/logistics/inventory"
    SITREP: Final[str] = "/api/v1/command/sitrep"

    # WebSocket Channels
    WS_TELEMETRY: Final[str] = "/ws/v1/telemetry"
    WS_ALERTS: Final[str] = "/ws/v1/alerts"

    @classmethod
    def get_ack_notification_route(cls, notification_id: str) -> str:
        """Helper to inject dynamic ID into the route pattern."""
        return cls.ACK_NOTIFICATION.format(id=notification_id)
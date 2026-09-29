"""
ResQVision Command - HTTP API Client
Handles REST communication with the FastAPI backend for ground station operations.
"""

from typing import Any, Dict, List, Optional
import httpx

from resq_command.api.routes import APIRoutes
from resq_command.db.models import (
    DroneTelemetry,
    IncidentTicket,
    InventoryItem,
    NotificationAlert,
    RescueSquad,
    StreamSource,
)


class ResQVisionAPIClient:
    """Client for FastAPI backend syncing tactical, intel, logistics, and command data."""

    def __init__(
        self,
        base_url: str = "http://127.0.0.1:8000",
        token: Optional[str] = None,
        timeout: float = 6.0,
    ):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.headers: Dict[str, str] = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        if token:
            self.set_token(token)

    def set_token(self, token: str):
        """Update bearer token for authenticated requests."""
        self.headers["Authorization"] = f"Bearer {token}"

    def _get_client(self) -> httpx.Client:
        return httpx.Client(
            base_url=self.base_url,
            headers=self.headers,
            timeout=self.timeout,
        )

    def _get_async_client(self) -> httpx.AsyncClient:
        return httpx.AsyncClient(
            base_url=self.base_url,
            headers=self.headers,
            timeout=self.timeout,
        )

    # -------------------------------------------------------------------------
    # Tactical & Fleet
    # -------------------------------------------------------------------------
    def get_drones(self) -> List[DroneTelemetry]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.DRONES)
            resp.raise_for_status()
            return [DroneTelemetry.model_validate(item) for item in resp.json()]

    async def get_drones_async(self) -> List[DroneTelemetry]:
        async with self._get_async_client() as client:
            resp = await client.get(APIRoutes.DRONES)
            resp.raise_for_status()
            return [DroneTelemetry.model_validate(item) for item in resp.json()]

    def get_rescue_teams(self) -> List[RescueSquad]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.TEAMS)
            resp.raise_for_status()
            return [RescueSquad.model_validate(item) for item in resp.json()]

    def dispatch_order(self, order_payload: Dict[str, Any]) -> Dict[str, Any]:
        with self._get_client() as client:
            resp = client.post(APIRoutes.DISPATCH_ORDER, json=order_payload)
            resp.raise_for_status()
            return resp.json()

    # -------------------------------------------------------------------------
    # Intel & Notifications
    # -------------------------------------------------------------------------
    def get_stream_sources(self) -> List[StreamSource]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.SOURCES)
            resp.raise_for_status()
            return [StreamSource.model_validate(item) for item in resp.json()]

    def get_notifications(self) -> List[NotificationAlert]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.NOTIFICATIONS)
            resp.raise_for_status()
            return [NotificationAlert.model_validate(item) for item in resp.json()]

    def acknowledge_notification(self, notification_id: str) -> bool:
        route = APIRoutes.get_ack_notification_route(notification_id)
        with self._get_client() as client:
            resp = client.post(route)
            return resp.status_code in [200, 204]

    # -------------------------------------------------------------------------
    # Command & Incidents
    # -------------------------------------------------------------------------
    def get_incidents(self) -> List[IncidentTicket]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.INCIDENTS)
            resp.raise_for_status()
            return [IncidentTicket.model_validate(item) for item in resp.json()]

    async def get_incidents_async(self) -> List[IncidentTicket]:
        async with self._get_async_client() as client:
            resp = await client.get(APIRoutes.INCIDENTS)
            resp.raise_for_status()
            return [IncidentTicket.model_validate(item) for item in resp.json()]

    def report_incident(self, incident: IncidentTicket) -> IncidentTicket:
        with self._get_client() as client:
            resp = client.post(APIRoutes.INCIDENTS, json=incident.to_dict())
            resp.raise_for_status()
            return IncidentTicket.model_validate(resp.json())

    def export_sitrep(self) -> bytes:
        """Download latest compiled SITREP summary/PDF from the backend."""
        with self._get_client() as client:
            resp = client.get(APIRoutes.SITREP)
            resp.raise_for_status()
            return resp.content

    # -------------------------------------------------------------------------
    # Logistics
    # -------------------------------------------------------------------------
    def get_inventory(self) -> List[InventoryItem]:
        with self._get_client() as client:
            resp = client.get(APIRoutes.INVENTORY)
            resp.raise_for_status()
            return [InventoryItem.model_validate(item) for item in resp.json()]

    async def get_inventory_async(self) -> List[InventoryItem]:
        async with self._get_async_client() as client:
            resp = await client.get(APIRoutes.INVENTORY)
            resp.raise_for_status()
            return [InventoryItem.model_validate(item) for item in resp.json()]
"""Client for shared backend account and telemetry APIs."""

from typing import Any, Dict, Optional

import httpx

from resq_command.api.routes import APIRoutes


class ResQVisionAPIClient:
    """Calls existing shared backend APIs; hardware control stays local."""

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

    def set_token(self, token: str) -> None:
        """Update or clear the bearer token used for authenticated requests."""
        if token:
            self.headers["Authorization"] = f"Bearer {token}"
        else:
            self.headers.pop("Authorization", None)

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

    def login(
        self,
        email: str,
        password: str,
        device_id: str,
        device_info: Optional[str] = None,
    ) -> Dict[str, Any]:
        payload = {
            "email": email,
            "password": password,
            "device_id": device_id,
            "device_info": device_info,
        }
        with self._get_client() as client:
            response = client.post(APIRoutes.LOGIN, json=payload)
            response.raise_for_status()
            result = response.json()

        if not isinstance(result, dict) or not isinstance(result.get("access_token"), str):
            raise ValueError("Backend login response did not include an access token.")
        self.set_token(result["access_token"])
        return result

    def get_current_user(self) -> Dict[str, Any]:
        with self._get_client() as client:
            response = client.get(APIRoutes.CURRENT_USER)
            response.raise_for_status()
            return response.json()

    def submit_telemetry(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        with self._get_client() as client:
            response = client.post(APIRoutes.TELEMETRY_RECEIVE, json=payload)
            response.raise_for_status()
            return response.json()

    def get_latest_telemetry(
        self,
        drone_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        with self._get_client() as client:
            response = client.get(APIRoutes.latest_telemetry(drone_id))
            response.raise_for_status()
            return response.json()

    async def get_current_user_async(self) -> Dict[str, Any]:
        async with self._get_async_client() as client:
            response = await client.get(APIRoutes.CURRENT_USER)
            response.raise_for_status()
            return response.json()

    async def submit_telemetry_async(
        self,
        payload: Dict[str, Any],
    ) -> Dict[str, Any]:
        async with self._get_async_client() as client:
            response = await client.post(APIRoutes.TELEMETRY_RECEIVE, json=payload)
            response.raise_for_status()
            return response.json()

    async def get_latest_telemetry_async(
        self,
        drone_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        async with self._get_async_client() as client:
            response = await client.get(APIRoutes.latest_telemetry(drone_id))
            response.raise_for_status()
            return response.json()

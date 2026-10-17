import httpx

from resq_command.api.client import ResQVisionAPIClient
from resq_command.api.routes import APIRoutes


def test_set_token_uses_bearer_authorization() -> None:
    client = ResQVisionAPIClient(token="operator-token")

    assert client.headers["Authorization"] == "Bearer operator-token"

    client.set_token("refreshed-token")
    assert client.headers["Authorization"] == "Bearer refreshed-token"

    client.set_token("")
    assert "Authorization" not in client.headers


def test_login_uses_existing_shared_backend_route_and_stores_access_token(
    monkeypatch,
) -> None:
    requests = []

    def handler(request: httpx.Request) -> httpx.Response:
        requests.append(request)
        return httpx.Response(
            200,
            json={
                "access_token": "access-token",
                "refresh_token": "refresh-token",
                "token_type": "bearer",
            },
        )

    client = ResQVisionAPIClient()
    monkeypatch.setattr(
        client,
        "_get_client",
        lambda: httpx.Client(
            base_url=client.base_url,
            transport=httpx.MockTransport(handler),
        ),
    )

    response = client.login(
        "operator@example.com",
        "password",
        "ground-station-1",
        "ResQCommand",
    )

    assert requests[0].url.path == "/auth/login"
    assert requests[0].read() == (
        b'{"email":"operator@example.com","password":"password",'
        b'"device_id":"ground-station-1","device_info":"ResQCommand"}'
    )
    assert response["access_token"] == "access-token"
    assert client.headers["Authorization"] == "Bearer access-token"


def test_latest_telemetry_path_encodes_drone_identifier() -> None:
    assert APIRoutes.latest_telemetry() == "/telemetry/latest"
    assert APIRoutes.latest_telemetry("drone/one") == "/telemetry/latest/drone%2Fone"

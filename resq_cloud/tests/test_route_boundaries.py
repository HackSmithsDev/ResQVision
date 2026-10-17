from app import app


def test_aircraft_commands_and_video_relay_routes_are_not_registered() -> None:
    paths = {route.path for route in app.routes}

    assert not any(path.startswith("/commands") for path in paths)
    assert not any("/stream/" in path or "/uplink/" in path for path in paths)


def test_shared_telemetry_sync_routes_remain_available() -> None:
    paths = {route.path for route in app.routes}

    assert "/auth/login" in paths
    assert "/users/me" in paths
    assert "/telemetry/receive" in paths
    assert "/telemetry/latest" in paths
    assert "/telemetry/latest/{drone_id}" in paths

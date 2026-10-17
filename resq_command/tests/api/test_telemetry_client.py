import json

from resq_command.api import telemetry_client


def test_udp_listener_emits_valid_json_objects_and_reports_bad_packets(
    monkeypatch,
) -> None:
    client = telemetry_client.UDPTelemetryClient()

    class FakeSocket:
        def __init__(self) -> None:
            self.packets = [
                b"{invalid",
                json.dumps({"drone_id": "drone-1", "battery": 81}).encode(),
            ]
            self.closed = False

        def bind(self, address) -> None:
            pass

        def settimeout(self, timeout) -> None:
            pass

        def recvfrom(self, buffer_size):
            packet = self.packets.pop(0)
            if not self.packets:
                client.is_running = False
            return packet, ("127.0.0.1", 14550)

        def close(self) -> None:
            self.closed = True

    fake_socket = FakeSocket()
    monkeypatch.setattr(telemetry_client.socket, "socket", lambda *_: fake_socket)
    packets = []
    errors = []
    statuses = []
    client.packet_received.connect(packets.append)
    client.error_occurred.connect(errors.append)
    client.connection_status_changed.connect(statuses.append)

    client.run()

    assert packets == [{"drone_id": "drone-1", "battery": 81}]
    assert len(errors) == 1
    assert "invalid telemetry datagram" in errors[0]
    assert statuses == [True, False]
    assert fake_socket.closed
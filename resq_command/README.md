# ResQVision Command

`resq_command` is the single PySide6 desktop ground station for operator-side monitoring. It reads local telemetry and the HDMI video capture device. The ELRS handset talks directly to the receiver on the FC722; aircraft commands and video do not pass through cloud routes or a second command service. Shared cloud data may use the existing backend API; this app does not expose its own server routes.

## Layout

- `src/resq_command/` — installable Python application package.
- `public/` — fonts, icons, and image resources used by the interface.
- `scripts/` — build, cleanup, and packaging helpers.
- `tests/api/`, `tests/ui/`, `tests/unit/` — API, UI, and unit tests.
- `pyproject.toml` — package metadata, dependencies, console entry point, and test configuration.

## Setup and run

From this folder, create and activate a virtual environment, then install the project in editable mode:

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
resq-command
```

The ELRS 2.4 GHz handset talks directly to the receiver wired to the FC722; `resq_command` and the cloud do not relay or originate those RC packets. By default, the app listens for local JSON/UDP telemetry; set `RESQ_ENABLE_MOCK_SIMULATOR=true` to enable demo telemetry. Betaflight MSP telemetry is not currently implemented. Connect the 5.8 GHz receiver's HDMI output through a capture card and set `RESQ_VIDEO_DEVICE_NAME` to that device's exact OS camera name. A local RTSP/HTTP URL can alternatively be configured with `RESQ_VIDEO_STREAM_URI`. Do not send radio commands or receiver video through cloud endpoints.

Shared operational records in the Command interface are loaded from authenticated `/workspace/{collection}` API routes. Set `RESQ_API_BASE_URL` to the backend origin (or keep the local-development default), then sign in from a workspace page. No demo fleet, team, inventory, alert, incident, or environmental records are shown by those pages.

Run `pytest` from this folder to include the Command tests.
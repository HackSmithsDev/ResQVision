# ResQVision

ResQVision is a modular drone response platform developed by HackSmiths. It brings together a mobile field app, a desktop ground station, a shared cloud backend, AI model-training/export pipelines, and flight-controller firmware.

## Repository modules

| Folder | Responsibility |
| --- | --- |
| [`resq_scout/`](./resq_scout/README.md) | Flutter mobile app for field operators and shared account/data features. |
| [`resq_command/`](./resq_command/README.md) | The single PySide6 desktop ground station for local telemetry and received video. |
| [`resq_cloud/`](./resq_cloud/README.md) | FastAPI backend for shared identity, user data, telemetry sync, and AI model state. It does not relay radio commands or video. |
| [`resq_ai/`](./resq_ai/README.md) | COCO dataset validation, aerial object-detector training/evaluation, image inference, and ONNX export for people, vehicles, and animals. |
| [`resq_flight/`](./resq_flight/README.md) | Flight-controller integration notes; the FC722 runs Betaflight firmware. |

## How the pieces connect

```text
Field operator
  ├── resq_scout (Flutter mobile app) ── HTTPS ──┐
  │                                               ▼
  │                                      resq_cloud (FastAPI)
  │                                       ├── PostgreSQL
  │                                       ├── Redis
  │                                       ├── Celery email worker
  │                                       └── Cloudflare Tunnel (optional ingress)
  │
  └── resq_command (single desktop ground station)
        ├── local JSON/UDP adapter ──► telemetry input
        └── 5.8 GHz video receiver ──HDMI──► capture card ──► local video input

Operator's ELRS 2.4 GHz remote ──radio──► ELRS receiver on FC722
      FC722 runs Betaflight; radio control stays on this direct link.
```

The local telemetry adapter's JSON/UDP format is an integration boundary, not native Betaflight MSP support. `resq_command` does not originate or relay flight commands; shared cloud APIs remain available for authentication and telemetry synchronization only.

`resq_ai` is a standalone aerial object-detection development workflow. It replaces the copied face-embedding code and does not perform face recognition. Its trained/exported model artifacts are not automatically loaded by the cloud API; model integration is a separate deployment step.

## Run the backend with Cloudflare Tunnel

The API container listens on `0.0.0.0:8000`. The `cloudflared` container joins the same Compose network and reaches it at `http://api:8000`. Configure the tunnel's public hostname/origin in Cloudflare Zero Trust to point to that URL. Compose also starts a Celery worker for queued emails. The tunnel is only for shared cloud features; command transmission and received video stay on the ground station and are not routed through the API.

1. Copy `resq_cloud/.env.example` to `resq_cloud/.env` and replace the required database, Redis, and secret values.
2. Copy the root `.env.example` to `.env` and set `CLOUDFLARE_TUNNEL_TOKEN`.
3. Start both services from the repository root:

   ```sh
   docker compose up --build
   ```

The API is also mapped to `127.0.0.1:8000` for local development. The tunnel token and backend secrets are supplied at runtime and are not included in the image. To run only the API, use `docker compose up --build api`.

See [`resq_cloud/README.md`](./resq_cloud/README.md) for backend configuration and tunnel details.

## Development notes

- Keep service-specific code and dependencies inside their module folders.
- Run cloud and AI tests from the repository root with `pytest`; run the Command tests from `resq_command/` with `pytest`.
- Do not commit `.env` files, credentials, private imagery, training datasets, model checkpoints, or generated model binaries.
- The AI detector expects separately organized train and validation splits with COCO-format bounding-box annotations; see [`resq_ai/README.md`](./resq_ai/README.md) before preparing data.
- Hardware interfaces and flight behavior must be tested safely on a bench before any flight.

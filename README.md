# ResQVision

ResQVision is a modular drone response platform developed by HackSmiths. It brings together a mobile ground station, a desktop command console, a cloud API, an AI model-training/export pipeline, and flight-controller firmware.

## Repository modules

| Folder | Responsibility |
| --- | --- |
| [`resq_scout/`](./resq_scout/README.md) | Flutter mobile app for field operators: account access, flight controls, camera/map views, and telemetry. |
| [`resq_command/`](./resq_command/README.md) | PySide6 desktop command and monitoring application. |
| [`resq_cloud/`](./resq_cloud/README.md) | FastAPI backend for identity, users, flight commands, telemetry, AI model state, and connections. |
| [`resq_ai/`](./resq_ai/README.md) | COCO dataset validation, aerial object-detector training/evaluation, image inference, and ONNX export for people, vehicles, and animals. |
| [`resq_flight/`](./resq_flight/README.md) | C firmware source for the flight-controller/companion hardware layer. |

## How the pieces connect

```text
Field operator
  ├── resq_scout (Flutter mobile app)
  └── resq_command (desktop command console)
             │ HTTPS / WebSocket
             ▼
      resq_cloud (FastAPI)
        ├── PostgreSQL — accounts and persistent application data
        ├── Redis — transient sessions, tokens, and active-control state
        ├── Celery worker — queued email delivery
        └── Cloudflare Tunnel — public ingress to the API; tunnel is a separate service
             │ 4G / telemetry link
             ▼
      Raspberry Pi companion computer
             │ UART / MSP
             ▼
      Flight controller (resq_flight)
```

`resq_ai` is a standalone aerial object-detection development workflow. It replaces the copied face-embedding code and does not perform face recognition. Its trained/exported model artifacts are not automatically loaded by the cloud API; model integration is a separate deployment step.

## Run the backend with Cloudflare Tunnel

The API container listens on `0.0.0.0:8000`. The `cloudflared` container joins the same Compose network and reaches it at `http://api:8000`. Configure the tunnel's public hostname/origin in Cloudflare Zero Trust to point to that URL. Compose also starts a Celery worker for queued emails.

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
- Do not commit `.env` files, credentials, private imagery, training datasets, model checkpoints, or generated model binaries.
- The AI detector expects separately organized train and validation splits with COCO-format bounding-box annotations; see [`resq_ai/README.md`](./resq_ai/README.md) before preparing data.
- Hardware interfaces and flight behavior must be tested safely on a bench before any flight.

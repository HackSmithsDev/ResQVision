# ResQVision Cloud API

`resq_cloud` is the FastAPI service used by the mobile and desktop clients. It handles authentication, user/admin operations, drone commands, connections, telemetry, and AI model state. PostgreSQL stores persistent records; Redis stores transient tokens, control state, and connection data.

## Layout

| Path | Responsibility |
| --- | --- |
| `app/core/` | Settings, logging, security helpers, and WebSocket support. |
| `app/db/` | SQLAlchemy base, async database session, ORM models, and seed commands. |
| `app/routers/` | HTTP/WebSocket API routes grouped by auth, users, admin, AI, commands, connection, and telemetry. |
| `app/schemas/` | Pydantic request and response schemas used by the routes. |
| `app/services/` | Application services; email notifications are enqueued here for Celery, while AI identification currently returns HTTP 501 until its provider/inference contract is implemented. |
| `app/utils/` | Shared integrations such as Redis and general helpers. |
| `app/workers/` | Celery application, task definitions, email transport, and beat schedule (currently no periodic jobs). |
| `alembic/` | Database migration environment and revision history. |
| `main.py` | Local/Uvicorn entry point. |
| `Dockerfile` | Production API image definition; builds with `resq_cloud` as its context. |

## Configuration

Copy `.env.example` to `.env` and supply real values for `SECRET_KEY`, `DATABASE_URL`, and `REDIS_URL`. Configure mail and AI provider credentials only when those integrations are enabled. Never commit `.env`.

The API uses `HOST`, `PORT`, `DEBUG`, and `WORKERS_COUNT` for its server process. Container defaults bind to `0.0.0.0:8000`, disable debug reload, and use one worker. Increase `WORKERS_COUNT` only after considering available CPU/memory and any database connection limits.

## Docker and Cloudflare Tunnel

From the repository root, start the API, email worker, and tunnel together:

```sh
cp resq_cloud/.env.example resq_cloud/.env
cp .env.example .env
# Edit both files with real service values.
docker compose up --build
```

In Cloudflare Zero Trust, configure the tunnel's public hostname to use the internal service URL `http://api:8000`. The `cloudflared` container is intentionally separate from the API image: it has its own lifecycle and receives the tunnel token from the root `.env` at runtime. The API image does not contain the token or `.env`.

The `worker` service runs `celery -A app.workers.celery_app:celery_app worker`. Signup, password-reset, account, login-alert, and approval emails are sent through the `resq_cloud.email.send` Celery task. The worker and API both need the same Redis and mail configuration.

For API-only local testing, run `docker compose up --build api`; the API is available at `http://127.0.0.1:8000` and its OpenAPI UI at `/docs`.

## Database

SQLAlchemy models are registered in `app/db/models/`. The application currently creates missing model tables during startup with `Base.metadata.create_all()`. This does not apply schema changes to existing tables.

**Migration caveat:** the checked-in Alembic history starts with `initial_skillinex_migration.py` and later revisions change course/lecture/practice tables; those revisions do not describe the current ResQVision ORM models. The historical revisions have not been rewritten because they may already be recorded in a deployed database. Do not use this Alembic chain to initialize or upgrade a production ResQVision database until its `alembic_version` and schema have been inspected and a safe baseline/forward-migration strategy has been agreed.

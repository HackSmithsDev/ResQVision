import os

os.environ.setdefault("SECRET_KEY", "test-only-secret")
os.environ.setdefault(
    "DATABASE_URL",
    "postgresql+asyncpg://test:test@127.0.0.1:5432/resq_test",
)
os.environ.setdefault("REDIS_URL", "redis://127.0.0.1:6379/15")

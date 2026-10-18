from __future__ import annotations

import json
from typing import Any
from urllib.parse import parse_qs, urlencode, urlparse, urlunparse

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # ======================
    # Project
    # ======================
    PROJECT_NAME: str = "ResQVision"
    ENVIRONMENT: str = "development"

    # ======================
    # Server
    # ======================
    HOST: str = "0.0.0.0"
    PORT: int = 8084
    DEBUG: bool = False
    WORKERS_COUNT: int = 1

    # ======================
    # Security
    # ======================
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # ======================
    # Database (Neon)
    # ======================
    DATABASE_URL: str
    DIRECT_URL: str | None = None

    @property
    def ASYNC_DATABASE_URL(self) -> str:
        """Convert standard postgresql:// URL to postgresql+asyncpg:// format with safe ssl params."""
        url = self.DATABASE_URL
        if url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)

        # asyncpg prefers ssl= instead of sslmode=
        parsed = urlparse(url)
        if parsed.query:
            query_params = parse_qs(parsed.query)
            if "sslmode" in query_params:
                val = query_params.pop("sslmode")[0]
                query_params["ssl"] = [
                    "require" if val in ("require", "verify-ca", "verify-full") else "disable"
                ]
            new_query = urlencode(query_params, doseq=True)
            url = urlunparse(parsed._replace(query=new_query))

        return url

    # ======================
    # Redis (Upstash)
    # ======================
    REDIS_URL: str

    # ======================
    # CORS
    # ======================
    BACKEND_CORS_ORIGINS: list[str] | str = ["*"]

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors(cls, v: Any) -> list[str]:
        if isinstance(v, str):
            if v.strip() == "*":
                return ["*"]
            try:
                parsed = json.loads(v)
                if isinstance(parsed, list):
                    return [str(i) for i in parsed]
            except Exception:
                return [i.strip() for i in v.split(",") if i.strip()]
        if isinstance(v, list):
            return [str(i) for i in v]
        return ["*"]

    # ======================
    # Email (SMTP)
    # ======================
    MAIL_USERNAME: str | None = None
    MAIL_PASSWORD: str | None = None
    MAIL_FROM: str | None = None
    MAIL_FROM_NAME: str | None = "ResQVision"
    MAIL_SERVER: str | None = None
    MAIL_PORT: int = 465

    # ======================
    # AI Keys
    # ======================
    GROQ_API_KEY: str | None = None
    GEMINI_API_KEY: str | None = None
    OPENAI_API_KEY: str | None = None
    GROK_API_KEY: str | None = None

    # ======================
    # Tactical AI (Ollama - Level 3)
    # ======================
    OLLAMA_BASE_URL: str = "http://ollama:11434"
    OLLAMA_MODEL: str = "resq-tactical:latest"
    OLLAMA_FALLBACK_MODEL: str = "llama3.2:3b"
    OLLAMA_TIMEOUT_SECONDS: float = 90.0

    # ======================
    # Admin
    # ======================
    ADMIN_EMAIL: str | None = None

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
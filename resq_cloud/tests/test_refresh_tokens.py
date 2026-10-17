from unittest.mock import AsyncMock

import pytest
from fastapi import HTTPException

from app.routers.auth import token as token_router
from app.schemas.auth import RefreshTokenRequest


@pytest.mark.asyncio
async def test_refresh_rotates_and_persists_refresh_token(monkeypatch) -> None:
    monkeypatch.setattr(
        token_router,
        "verify_token",
        lambda token, expected_type: "operator-1",
    )
    monkeypatch.setattr(
        token_router,
        "get_refresh_token",
        AsyncMock(return_value="old-refresh"),
    )
    monkeypatch.setattr(
        token_router,
        "create_access_token",
        lambda subject: "new-access",
    )
    monkeypatch.setattr(
        token_router,
        "create_refresh_token",
        lambda subject: "new-refresh",
    )
    store_refresh_token = AsyncMock()
    monkeypatch.setattr(token_router, "set_refresh_token", store_refresh_token)

    response = await token_router.refresh_token(
        RefreshTokenRequest(refresh_token="old-refresh")
    )

    assert response == {
        "access_token": "new-access",
        "refresh_token": "new-refresh",
        "token_type": "bearer",
    }
    store_refresh_token.assert_awaited_once_with(
        user_id="operator-1",
        token="new-refresh",
        expire_seconds=token_router.settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60,
    )


@pytest.mark.asyncio
async def test_refresh_rejects_a_revoked_refresh_token(monkeypatch) -> None:
    monkeypatch.setattr(
        token_router,
        "verify_token",
        lambda token, expected_type: "operator-1",
    )
    monkeypatch.setattr(
        token_router,
        "get_refresh_token",
        AsyncMock(return_value="different-refresh"),
    )
    store_refresh_token = AsyncMock()
    monkeypatch.setattr(token_router, "set_refresh_token", store_refresh_token)

    with pytest.raises(HTTPException) as error:
        await token_router.refresh_token(
            RefreshTokenRequest(refresh_token="revoked-refresh")
        )

    assert error.value.status_code == 401
    store_refresh_token.assert_not_awaited()

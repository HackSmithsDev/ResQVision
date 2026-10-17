from fastapi import APIRouter, HTTPException

from app.core.config import settings
from app.core.security import create_access_token, create_refresh_token, verify_token
from app.schemas.auth import (
    MessageResponse,
    RefreshTokenRequest,
    TokenResponse,
    VerifyTokenRequest,
)
from app.utils.redis import get_refresh_token, set_refresh_token

router = APIRouter()


@router.post("/token/refresh", response_model=TokenResponse)
async def refresh_token(data: RefreshTokenRequest):
    user_id = verify_token(data.refresh_token, expected_type="refresh")

    stored_token = await get_refresh_token(user_id)
    if not stored_token or stored_token != data.refresh_token:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    new_access_token = create_access_token(subject=user_id)
    new_refresh_token = create_refresh_token(subject=user_id)
    await set_refresh_token(
        user_id=user_id,
        token=new_refresh_token,
        expire_seconds=settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60,
    )

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer"
    }


@router.post("/token/verify", response_model=MessageResponse)
async def verify_access_token(data: VerifyTokenRequest):
    verify_token(data.token, expected_type="access")
    return {"message": "Token is valid"}
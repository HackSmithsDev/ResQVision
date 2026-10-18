from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.db.session import get_db
from app.db.models.account import User
from app.db.models.intelligence import AIModel, AIRequest
from app.schemas.ai import IdentifyRequest, IdentifyResponse
from app.core.security import get_current_user
from app.utils.helper import generate_unique_id
from app.utils.redis import set_active_ai_model, revoke_active_ai_model

router = APIRouter()


@router.post("/identify", response_model=IdentifyResponse)
async def identify(
    data: IdentifyRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    # 1. Fetch model from DB and verify it is active
    result = await db.execute(
        select(AIModel).where(
            AIModel.key == data.application, 
            AIModel.is_active == True
        )
    )
    model = result.scalars().first()

    if not model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="AI application not found or inactive"
        )

    # 2. Log initial AI Request entry in Postgres
    ai_request = AIRequest(
        id=generate_unique_id(),
        user_id=current_user.id,
        model_id=model.id,
        application=data.application,
        level=str(data.level),
        input_data={"data": str(data.data)[:500]},  # Store truncated preview
        status="processing"
    )
    db.add(ai_request)
    await db.commit()
    await db.refresh(ai_request)

    # 3. Mark model as currently "in play" in Redis
    await set_active_ai_model(
        model_key=data.application,
        metadata={
            "request_id": ai_request.id,
            "user_id": current_user.id,
            "provider": data.preferred_provider or model.provider,
            "started_at": datetime.now(timezone.utc).isoformat()
        }
    )

    try:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=(
                "AI inference is unavailable until a trained checkpoint and inference "
                "runtime are configured on the backend."
            ),
        )

    except HTTPException as exc:
        # 6. Mark DB request record as failed
        ai_request.status = "failed"
        ai_request.result = {"error": exc.detail}
        await db.commit()
        raise
    except Exception as exc:
        ai_request.status = "failed"
        ai_request.result = {"error": "AI identification failed"}
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="AI identification failed",
        ) from exc

    finally:
        # 7. Always remove model from "in play" state in Redis when processing finishes
        await revoke_active_ai_model(data.application)
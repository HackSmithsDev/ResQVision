from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_current_user
from app.db.models.account import User
from app.db.models.workspace import WorkspaceRecord
from app.db.session import get_db
from app.schemas.workspace import (
    WorkspaceRecordCreate,
    WorkspaceRecordResponse,
    WorkspaceRecordUpdate,
)
router = APIRouter()
WORKSPACE_COLLECTIONS = frozenset(
    {
        "drones",
        "missions",
        "reports",
        "teams",
        "messages",
        "inventory",
        "incidents",
        "notifications",
        "emergency-actions",
        "ai-insights",
        "environmental-readings",
    }
)


def validate_collection(collection: str) -> None:
    if collection not in WORKSPACE_COLLECTIONS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workspace collection not found",
        )


async def get_record(
    db: AsyncSession,
    user: User,
    collection: str,
    record_id: str,
) -> WorkspaceRecord:
    result = await db.execute(
        select(WorkspaceRecord).where(
            WorkspaceRecord.id == record_id,
            WorkspaceRecord.owner_id == user.id,
            WorkspaceRecord.collection == collection,
        )
    )
    record = result.scalars().first()
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workspace record not found",
        )
    return record


@router.get("/{collection}", response_model=list[WorkspaceRecordResponse])
async def list_workspace_records(
    collection: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    validate_collection(collection)
    result = await db.execute(
        select(WorkspaceRecord)
        .where(
            WorkspaceRecord.owner_id == current_user.id,
            WorkspaceRecord.collection == collection,
        )
        .order_by(WorkspaceRecord.created_at.desc())
        .limit(500)
    )
    return list(result.scalars().all())


@router.post(
    "/{collection}",
    response_model=WorkspaceRecordResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_workspace_record(
    collection: str,
    payload: WorkspaceRecordCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    validate_collection(collection)
    record = WorkspaceRecord(
        owner_id=current_user.id,
        collection=collection,
        data=payload.data,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)
    return record


@router.put("/{collection}/{record_id}", response_model=WorkspaceRecordResponse)
async def update_workspace_record(
    collection: str,
    record_id: str,
    payload: WorkspaceRecordUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    validate_collection(collection)
    record = await get_record(db, current_user, collection, record_id)
    record.data = payload.data
    await db.commit()
    await db.refresh(record)
    return record


@router.delete(
    "/{collection}/{record_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
)
async def delete_workspace_record(
    collection: str,
    record_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    validate_collection(collection)
    record = await get_record(db, current_user, collection, record_id)
    await db.delete(record)
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)

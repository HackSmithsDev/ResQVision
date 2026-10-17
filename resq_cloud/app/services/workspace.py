from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.account import User
from app.db.models.workspace import WorkspaceRecord

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


def validate_collection(collection: str) -> str:
    if collection not in WORKSPACE_COLLECTIONS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workspace collection not found",
        )
    return collection


async def list_records(
    db: AsyncSession,
    user: User,
    collection: str,
) -> list[WorkspaceRecord]:
    validate_collection(collection)
    result = await db.execute(
        select(WorkspaceRecord)
        .where(
            WorkspaceRecord.owner_id == user.id,
            WorkspaceRecord.collection == collection,
        )
        .order_by(WorkspaceRecord.created_at.desc())
        .limit(500)
    )
    return list(result.scalars().all())


async def create_record(
    db: AsyncSession,
    user: User,
    collection: str,
    data: dict,
) -> WorkspaceRecord:
    validate_collection(collection)
    record = WorkspaceRecord(
        owner_id=user.id,
        collection=collection,
        data=data,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)
    return record


async def get_record(
    db: AsyncSession,
    user: User,
    collection: str,
    record_id: str,
) -> WorkspaceRecord:
    validate_collection(collection)
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


async def update_record(
    db: AsyncSession,
    user: User,
    collection: str,
    record_id: str,
    data: dict,
) -> WorkspaceRecord:
    record = await get_record(db, user, collection, record_id)
    record.data = data
    await db.commit()
    await db.refresh(record)
    return record


async def delete_record(
    db: AsyncSession,
    user: User,
    collection: str,
    record_id: str,
) -> None:
    record = await get_record(db, user, collection, record_id)
    await db.delete(record)
    await db.commit()

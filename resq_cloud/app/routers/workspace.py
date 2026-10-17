from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_current_user
from app.db.models.account import User
from app.db.session import get_db
from app.schemas.workspace import (
    WorkspaceRecordCreate,
    WorkspaceRecordResponse,
    WorkspaceRecordUpdate,
)
from app.services import workspace

router = APIRouter()


@router.get("/{collection}", response_model=list[WorkspaceRecordResponse])
async def list_workspace_records(
    collection: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await workspace.list_records(db, current_user, collection)


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
    return await workspace.create_record(
        db,
        current_user,
        collection,
        payload.data,
    )


@router.put("/{collection}/{record_id}", response_model=WorkspaceRecordResponse)
async def update_workspace_record(
    collection: str,
    record_id: str,
    payload: WorkspaceRecordUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await workspace.update_record(
        db,
        current_user,
        collection,
        record_id,
        payload.data,
    )


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
    await workspace.delete_record(db, current_user, collection, record_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)

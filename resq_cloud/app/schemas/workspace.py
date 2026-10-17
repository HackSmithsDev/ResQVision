from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class WorkspaceRecordCreate(BaseModel):
    data: dict[str, Any] = Field(min_length=1)


class WorkspaceRecordUpdate(BaseModel):
    data: dict[str, Any] = Field(min_length=1)


class WorkspaceRecordResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    collection: str
    data: dict[str, Any]
    created_at: datetime
    updated_at: datetime

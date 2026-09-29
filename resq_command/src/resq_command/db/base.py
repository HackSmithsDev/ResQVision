"""Base model foundation for all ResQVision client-side data structures."""

from datetime import datetime
from typing import Any, Dict
from pydantic import BaseModel, ConfigDict, Field


class BaseClientModel(BaseModel):
    """Base Pydantic model for desktop client data schemas."""

    model_config = ConfigDict(
        populate_by_name=True,
        validate_assignment=True,
        arbitrary_types_allowed=True,
        from_attributes=True,
    )

    created_at: datetime = Field(default_factory=datetime.utcnow)

    def to_dict(self) -> Dict[str, Any]:
        """Convert model to standard dictionary."""
        return self.model_dump()

    def to_json_str(self) -> str:
        """Convert model to JSON string."""
        return self.model_dump_json()
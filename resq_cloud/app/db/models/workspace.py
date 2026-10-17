from sqlalchemy import Column, DateTime, ForeignKey, Index, JSON, String
from sqlalchemy.sql import func

from app.db.base import Base
from app.utils.helper import generate_unique_id


class WorkspaceRecord(Base):
    __tablename__ = "workspace_records"
    __table_args__ = (
        Index("ix_workspace_owner_collection", "owner_id", "collection"),
    )

    id = Column(String, primary_key=True, default=generate_unique_id)
    owner_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    collection = Column(String(40), nullable=False)
    data = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

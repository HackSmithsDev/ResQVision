from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Base class for all database models"""
    pass


# Import all models so Alembic can detect them
from app.db.models.account import User, Device, AdminLog
from app.db.models.operations import Connection, EventLog
from app.db.models.intelligence import AIModel, AIRequest
from app.db.models.workspace import WorkspaceRecord

metadata = Base.metadata
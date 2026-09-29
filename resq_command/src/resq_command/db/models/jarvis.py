"""Jarvis AI schemas: intent parsing, voice states, and audit trails."""

from typing import Any, Dict, Optional
from pydantic import Field
from resq_command.db.base import BaseClientModel


class JarvisIntent(BaseClientModel):
    """Parsed operational intent from voice speech recognition."""

    action: str  # e.g., "deploy_drone", "set_geofence", "rtl_all"
    target_id: Optional[str] = None
    parameters: Dict[str, Any] = Field(default_factory=dict)
    confidence: float = Field(default=1.0, ge=0.0, le=1.0)
    raw_transcript: str = ""


class JarvisVoiceState(BaseClientModel):
    """Current state of the Siri/Jarvis voice engine."""

    state: str = "IDLE"  # IDLE, LISTENING, THINKING, EXECUTING, SPEAKING
    transcript: str = ""
    last_response: str = ""


class JarvisActionAudit(BaseClientModel):
    """Audit log entry of an AI-dispatched tactical command."""

    audit_id: str
    operator: str = "TACTICAL_COMMANDER"
    action_dispatched: str
    parameters: Dict[str, Any] = Field(default_factory=dict)
    execution_success: bool = True
    error_message: Optional[str] = None
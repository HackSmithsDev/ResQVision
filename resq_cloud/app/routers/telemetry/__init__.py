from fastapi import APIRouter

from .receive import router as receive_router
from .latest import router as latest_router

router = APIRouter()

router.include_router(receive_router, tags=["Telemetry"])
router.include_router(latest_router, tags=["Telemetry"])
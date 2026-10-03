from celery import Celery
from app.core.config import settings
from app.workers.beat_schedule import CELERY_BEAT_SCHEDULE

celery_app = Celery(
    "resqvision_workers",
    broker=settings.REDIS_URL,
    include=["app.workers.tasks.email.sender"],
)

celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="Asia/Kolkata",
    enable_utc=True,
    task_track_started=True,
    beat_schedule=CELERY_BEAT_SCHEDULE,
    task_ignore_result=True,
    task_time_limit=900,
    worker_concurrency=1,
    worker_prefetch_multiplier=1
)
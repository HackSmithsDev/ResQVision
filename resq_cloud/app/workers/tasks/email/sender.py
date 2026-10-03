import asyncio

from app.workers import celery_app
from app.workers.tasks.email import send_email


@celery_app.task(name="resq_cloud.email.send", ignore_result=True)
def send_email_task(subject: str, recipients: list[str], html: str) -> None:
    asyncio.run(send_email(subject=subject, recipients=recipients, html=html))
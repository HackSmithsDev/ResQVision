import asyncio
from typing import Optional

from app.core.config import settings
from app.workers import celery_app
from app.workers.tasks.email import send_email
from app.workers.tasks.email.templates import (
    APPROVAL_RESULT_HTML,
    DELETE_ACCOUNT_HTML,
    LOGIN_ALERT_HTML,
    NEW_USER_REQUEST_HTML,
    OTP_HTML,
    RESET_SUCCESS_HTML,
    WELCOME_HTML,
)


@celery_app.task(name="resq_cloud.email.send", ignore_result=True)
def send_email_task(subject: str, recipients: list[str], html: str) -> None:
    asyncio.run(send_email(subject=subject, recipients=recipients, html=html))


async def _enqueue_email(
    subject: str,
    recipients: list[str],
    html: str,
    *,
    expires: Optional[int] = None,
) -> None:
    await asyncio.to_thread(
        send_email_task.apply_async,
        kwargs={"subject": subject, "recipients": recipients, "html": html},
        expires=expires,
    )


async def send_welcome_email(email: str, username: str) -> None:
    await _enqueue_email("Welcome to ResQVision", [email], WELCOME_HTML.format(username=username))


async def send_otp_email(email: str, username: str, code: str) -> None:
    await _enqueue_email(
        f"{code} is your ResQVision code",
        [email],
        OTP_HTML.format(username=username, code=code),
        expires=600,
    )


async def send_login_alert(email: str, username: str, time: str) -> None:
    await _enqueue_email(
        "Security Alert: New Login Detected",
        [email],
        LOGIN_ALERT_HTML.format(username=username, time=time),
    )


async def send_reset_success_email(email: str, username: str) -> None:
    await _enqueue_email(
        "Password Reset Successful",
        [email],
        RESET_SUCCESS_HTML.format(username=username),
    )


async def send_delete_account_email(email: str, username: str) -> None:
    await _enqueue_email("Account Deleted", [email], DELETE_ACCOUNT_HTML.format(username=username))


async def send_approval_result_email(
    email: str,
    username: str,
    status: str,
    message: str = "",
) -> None:
    await _enqueue_email(
        f"Account {status} - ResQVision",
        [email],
        APPROVAL_RESULT_HTML.format(username=username, status=status, message=message),
    )


async def send_new_user_request_email(username: str, email: str) -> None:
    if not settings.ADMIN_EMAIL:
        raise RuntimeError("ADMIN_EMAIL must be configured to notify the administrator.")
    await _enqueue_email(
        "New User Access Request - ResQVision",
        [settings.ADMIN_EMAIL],
        NEW_USER_REQUEST_HTML.format(username=username, email=email),
    )
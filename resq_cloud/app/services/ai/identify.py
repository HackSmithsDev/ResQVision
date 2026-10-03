from typing import Any, Optional

from fastapi import HTTPException, status


async def identify(
    input_data: dict[str, Any],
    application: str,
    preferred_provider: Optional[str],
    enhance_with_llm: bool,
) -> dict[str, Any]:
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="AI identification is not configured yet.",
    )

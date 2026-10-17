from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException

from app.db.models.account import User
from app.db.models.workspace import WorkspaceRecord
from app.services import workspace


@pytest.mark.asyncio
async def test_workspace_records_are_scoped_to_owner_and_collection() -> None:
    user = User(id="operator-1")
    expected = [WorkspaceRecord(id="mission-1", owner_id=user.id, collection="missions", data={"title": "Search"})]
    result = MagicMock()
    result.scalars.return_value.all.return_value = expected
    db = AsyncMock()
    db.execute.return_value = result

    records = await workspace.list_records(db, user, "missions")

    assert records == expected
    statement = str(db.execute.await_args.args[0])
    assert "workspace_records.owner_id" in statement
    assert "workspace_records.collection" in statement


@pytest.mark.asyncio
async def test_unknown_workspace_collection_is_rejected() -> None:
    db = AsyncMock()

    with pytest.raises(HTTPException) as error:
        await workspace.list_records(db, User(id="operator-1"), "not-a-collection")

    assert error.value.status_code == 404
    db.execute.assert_not_awaited()


@pytest.mark.asyncio
async def test_workspace_record_can_be_created_for_an_allowed_collection() -> None:
    user = User(id="operator-1")
    db = AsyncMock()
    db.add = MagicMock()

    record = await workspace.create_record(
        db,
        user,
        "environmental-readings",
        {"sensor": "field-unit", "value": 12},
    )

    assert record.owner_id == user.id
    assert record.collection == "environmental-readings"
    assert record.data == {"sensor": "field-unit", "value": 12}
    db.add.assert_called_once_with(record)
    db.commit.assert_awaited_once()


@pytest.mark.asyncio
async def test_missing_record_cannot_be_read_or_mutated() -> None:
    result = MagicMock()
    result.scalars.return_value.first.return_value = None
    db = AsyncMock()
    db.execute.return_value = result

    with pytest.raises(HTTPException) as error:
        await workspace.get_record(
            db,
            User(id="operator-1"),
            "missions",
            "not-owned",
        )

    assert error.value.status_code == 404
    db.commit.assert_not_awaited()


def test_workspace_collection_routes_are_registered() -> None:
    from app import app

    paths = {route.path for route in app.routes}

    assert "/workspace/{collection}" in paths
    assert "/workspace/{collection}/{record_id}" in paths

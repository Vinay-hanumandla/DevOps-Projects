"""The items resource, exercised end to end against the in-memory database."""
# last_verified: 2026-10-03 · python n/a

from fastapi.testclient import TestClient
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import Item


def test_create_returns_server_assigned_fields(client: TestClient) -> None:
    response = client.post("/items", json={"name": "first"})

    assert response.status_code == 201
    body = response.json()
    assert body["name"] == "first"
    assert body["id"] >= 1
    assert body["created_at"] is not None


def test_duplicate_name_is_a_conflict(client: TestClient) -> None:
    first = client.post("/items", json={"name": "first"})
    assert first.status_code == 201

    second = client.post("/items", json={"name": "first"})

    assert second.status_code == 409


def test_list_returns_items_oldest_first(client: TestClient) -> None:
    client.post("/items", json={"name": "first"})
    client.post("/items", json={"name": "second"})

    response = client.get("/items")

    assert response.status_code == 200
    assert [item["name"] for item in response.json()] == ["first", "second"]


def test_unknown_id_is_not_found(client: TestClient) -> None:
    response = client.get("/items/4242")

    assert response.status_code == 404


def test_validation_failure_writes_nothing(client: TestClient, session: Session) -> None:
    response = client.post("/items", json={"name": ""})

    assert response.status_code == 422
    stored = session.execute(select(func.count()).select_from(Item)).scalar_one()
    assert stored == 0
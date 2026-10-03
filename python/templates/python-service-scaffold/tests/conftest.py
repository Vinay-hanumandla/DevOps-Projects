"""Fixtures: one isolated in-memory database per test, plus a client bound to it."""
# last_verified: 2026-10-03 · python n/a

from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import Base, get_session
from app.main import app


@pytest.fixture()
def db_engine() -> Iterator[Engine]:
    """An in-memory database shared by every connection used during the test.

    StaticPool keeps one connection alive for the whole test, and
    check_same_thread=False lets the test's thread and the application worker's
    thread both use it. Without both, an in-memory SQLite database created in the
    test is invisible to the request handlers.
    """
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    engine.dispose()


@pytest.fixture()
def session(db_engine: Engine) -> Iterator[Session]:
    """A session the test and the application share."""
    factory = sessionmaker(bind=db_engine, autoflush=False, expire_on_commit=False)
    with factory() as db_session:
        yield db_session


@pytest.fixture()
def client(session: Session) -> Iterator[TestClient]:
    """A test client whose requests resolve ``get_session`` to the in-memory database."""

    def override_get_session() -> Iterator[Session]:
        yield session

    app.dependency_overrides[get_session] = override_get_session
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
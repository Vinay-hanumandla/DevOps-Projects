"""Database engine, session factory, and the request-scoped session dependency."""
# last_verified: 2026-10-03 · python n/a

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.config import get_settings


class Base(DeclarativeBase):
    """Declarative base that every ORM model in this service inherits from."""


def build_engine(url: str | None = None) -> Engine:
    """Create an engine, defaulting to the configured database.

    ``pool_pre_ping`` discards connections the server has already dropped, which
    is the usual cause of a stale-connection error after an idle period. The
    ``url`` argument exists for tests and one-off tooling.
    """
    settings = get_settings()
    return create_engine(
        settings.database_url if url is None else url,
        echo=settings.sql_echo,
        pool_pre_ping=True,
        pool_recycle=1800,
    )


engine: Engine = build_engine()

SessionFactory = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_session() -> Iterator[Session]:
    """FastAPI dependency yielding a session and always closing it afterwards."""
    with SessionFactory() as session:
        yield session
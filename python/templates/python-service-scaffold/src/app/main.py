"""HTTP surface: liveness, readiness, and a minimal resource over the items table."""
# last_verified: 2026-10-03 · python n/a

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy import select, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.config import get_settings
from app.db import engine, get_session
from app.models import Item
from app.schemas import ItemCreate, ItemRead

settings = get_settings()
SessionDep = Annotated[Session, Depends(get_session)]


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    """Dispose of the pooled connections when the process shuts down."""
    yield
    engine.dispose()


app = FastAPI(title=settings.app_name, lifespan=lifespan)


@app.get("/healthz")
def healthz() -> dict[str, str]:
    """Liveness. Deliberately answers without touching the database."""
    return {"app": settings.app_name, "environment": settings.environment, "status": "ok"}


@app.get("/healthz/ready")
def ready(session: SessionDep) -> dict[str, str]:
    """Readiness. Runs a probe query so an unreachable database fails the check."""
    try:
        session.execute(text("SELECT 1"))
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="database is not reachable",
        ) from exc
    return {"database": "ok"}


@app.get("/items", response_model=list[ItemRead])
def list_items(session: SessionDep) -> list[Item]:
    """Every item, oldest first."""
    return list(session.scalars(select(Item).order_by(Item.id)).all())


@app.post("/items", response_model=ItemRead, status_code=status.HTTP_201_CREATED)
def create_item(payload: ItemCreate, session: SessionDep) -> Item:
    """Create an item. Names are unique, so a repeat is a conflict, not a duplicate row."""
    if session.scalar(select(Item).where(Item.name == payload.name)) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"item {payload.name!r} already exists",
        )
    item = Item(name=payload.name)
    session.add(item)
    session.commit()
    # Server-assigned columns are only populated after a refresh.
    session.refresh(item)
    return item


@app.get("/items/{item_id}", response_model=ItemRead)
def get_item(item_id: int, session: SessionDep) -> Item:
    """Fetch one item by primary key."""
    item = session.get(Item, item_id)
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="item not found")
    return item
"""Request and response models for the HTTP layer."""
# last_verified: 2026-10-03 · python n/a

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ItemCreate(BaseModel):
    """Payload accepted by item creation."""

    name: str = Field(min_length=1, max_length=120, examples=["first-item"])


class ItemRead(BaseModel):
    """Item representation returned to clients, built straight from the ORM object."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    created_at: datetime
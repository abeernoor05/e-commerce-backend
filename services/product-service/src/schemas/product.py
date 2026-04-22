from datetime import datetime

from pydantic import BaseModel, Field


class ProductCreateRequest(BaseModel):
    name: str = Field(min_length=2, max_length=255)
    description: str | None = Field(default=None, max_length=1000)
    category: str = Field(min_length=2, max_length=100)
    price: float = Field(gt=0)
    inventory_count: int = Field(ge=0)


class ProductResponse(BaseModel):
    id: int
    name: str
    description: str | None
    category: str
    price: float
    inventory_count: int
    created_at: datetime

    model_config = {
        "from_attributes": True,
    }


class InventoryUpdateRequest(BaseModel):
    inventory_count: int = Field(ge=0)


class ReserveInventoryRequest(BaseModel):
    quantity: int = Field(ge=1)


class ReserveInventoryResponse(BaseModel):
    product_id: int
    reserved_quantity: int
    remaining_inventory: int


class AvailabilityResponse(BaseModel):
    product_id: int
    requested_quantity: int
    available: bool
    current_inventory: int

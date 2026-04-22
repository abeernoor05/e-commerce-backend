from datetime import datetime

from pydantic import BaseModel, Field


class OrderCreateRequest(BaseModel):
    product_id: int = Field(ge=1)
    quantity: int = Field(ge=1)


class OrderResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    status: str
    created_at: datetime

    model_config = {
        "from_attributes": True,
    }


class InventoryAvailability(BaseModel):
    product_id: int
    requested_quantity: int
    available: bool
    current_inventory: int


class InventoryReserveResponse(BaseModel):
    product_id: int
    reserved_quantity: int
    remaining_inventory: int

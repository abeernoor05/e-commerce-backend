from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from src.core.database import get_db
from src.models.product import Product
from src.schemas.product import (
    AvailabilityResponse,
    InventoryUpdateRequest,
    ProductCreateRequest,
    ProductResponse,
    ReserveInventoryRequest,
    ReserveInventoryResponse,
)

router = APIRouter(prefix="/products", tags=["products"])


@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(payload: ProductCreateRequest, db: Session = Depends(get_db)) -> Product:
    product = Product(
        name=payload.name,
        description=payload.description,
        category=payload.category,
        price=payload.price,
        inventory_count=payload.inventory_count,
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


@router.get("", response_model=list[ProductResponse])
def list_products(
    category: str | None = Query(default=None),
    in_stock_only: bool = Query(default=False),
    db: Session = Depends(get_db),
) -> list[Product]:
    query = db.query(Product)
    if category:
        query = query.filter(Product.category == category)
    if in_stock_only:
        query = query.filter(Product.inventory_count > 0)
    return query.order_by(Product.id.desc()).all()


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)) -> Product:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    return product


@router.patch("/{product_id}/inventory", response_model=ProductResponse)
def update_inventory(
    product_id: int,
    payload: InventoryUpdateRequest,
    db: Session = Depends(get_db),
) -> Product:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    product.inventory_count = payload.inventory_count
    db.commit()
    db.refresh(product)
    return product


@router.get("/{product_id}/availability", response_model=AvailabilityResponse)
def check_availability(
    product_id: int,
    quantity: int = Query(ge=1, default=1),
    db: Session = Depends(get_db),
) -> AvailabilityResponse:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    return AvailabilityResponse(
        product_id=product.id,
        requested_quantity=quantity,
        available=product.inventory_count >= quantity,
        current_inventory=product.inventory_count,
    )


@router.post("/{product_id}/reserve", response_model=ReserveInventoryResponse)
def reserve_inventory(
    product_id: int,
    payload: ReserveInventoryRequest,
    db: Session = Depends(get_db),
) -> ReserveInventoryResponse:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    if product.inventory_count < payload.quantity:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Insufficient inventory",
        )

    product.inventory_count -= payload.quantity
    db.commit()
    db.refresh(product)

    return ReserveInventoryResponse(
        product_id=product.id,
        reserved_quantity=payload.quantity,
        remaining_inventory=product.inventory_count,
    )

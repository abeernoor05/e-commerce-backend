from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from src.clients.product_client import ProductServiceClient
from src.core.database import get_db
from src.models.order import Order
from src.schemas.order import OrderCreateRequest, OrderResponse

router = APIRouter(prefix="/orders", tags=["orders"])
product_client = ProductServiceClient()


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(payload: OrderCreateRequest, db: Session = Depends(get_db)) -> Order:
    try:
        availability = product_client.check_availability(payload.product_id, payload.quantity)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Product service unavailable",
        ) from exc

    if not availability.available:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Insufficient inventory for requested product",
        )

    try:
        product_client.reserve_inventory(payload.product_id, payload.quantity)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to reserve inventory",
        ) from exc

    order = Order(
        product_id=payload.product_id,
        quantity=payload.quantity,
        status="confirmed",
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


@router.get("/{order_id}", response_model=OrderResponse)
def get_order(order_id: int, db: Session = Depends(get_db)) -> Order:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return order


@router.get("", response_model=list[OrderResponse])
def list_orders(db: Session = Depends(get_db)) -> list[Order]:
    return db.query(Order).order_by(Order.id.desc()).all()

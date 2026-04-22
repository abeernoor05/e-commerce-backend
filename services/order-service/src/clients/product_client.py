import httpx

from src.core.config import PRODUCT_SERVICE_URL
from src.schemas.order import InventoryAvailability, InventoryReserveResponse


class ProductServiceClient:
    def __init__(self, base_url: str = PRODUCT_SERVICE_URL) -> None:
        self.base_url = base_url.rstrip("/")

    def check_availability(self, product_id: int, quantity: int) -> InventoryAvailability:
        url = f"{self.base_url}/products/{product_id}/availability"
        response = httpx.get(url, params={"quantity": quantity}, timeout=5.0)
        response.raise_for_status()
        return InventoryAvailability(**response.json())

    def reserve_inventory(self, product_id: int, quantity: int) -> InventoryReserveResponse:
        url = f"{self.base_url}/products/{product_id}/reserve"
        response = httpx.post(url, json={"quantity": quantity}, timeout=5.0)
        response.raise_for_status()
        return InventoryReserveResponse(**response.json())

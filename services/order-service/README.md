# order-service

Order management microservice with synchronous inventory validation.

## Responsibilities

- create customer orders
- retrieve and list orders
- validate and reserve inventory through product-service

## API Endpoints

- GET /health
- POST /orders
- GET /orders/{order_id}
- GET /orders

## Runtime Configuration

Common environment variables:

- DATABASE_URL
- PRODUCT_SERVICE_URL
- SERVICE_NAME

## Source Layout

- src/main.py: application bootstrap and middleware setup
- src/api/routes_orders.py: order endpoints and orchestration logic
- src/clients/product_client.py: product-service HTTP client
- src/core/database.py: SQLAlchemy engine/session wiring
- src/models/order.py: order ORM model
- src/schemas/order.py: request and response schemas

## Local Run

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

Open API docs:

- http://localhost:8000/docs

## Integration Notes

- POST /orders checks stock and reserves inventory before persisting an order
- temporary product-service failure returns gateway-style error response
- CORS is enabled for browser-based project demo usage

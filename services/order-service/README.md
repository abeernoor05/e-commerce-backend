# order-service

Responsibilities:
- Create order
- Track order
- Validate stock by calling product-service

## Implemented Endpoints
- `GET /health`: service health check
- `POST /orders`: create an order after checking and reserving inventory in product-service
- `GET /orders/{order_id}`: fetch one order
- `GET /orders`: list all orders

## Code Map
- `src/main.py`: app bootstrap, router registration, DB init
- `src/core/config.py`: environment-based settings
- `src/core/database.py`: SQLAlchemy engine/session/base
- `src/models/order.py`: order table model
- `src/schemas/order.py`: request/response models
- `src/clients/product_client.py`: REST client for product-service
- `src/api/routes_orders.py`: order handlers and product-service integration

## Local Quick Test
1. Create venv and install dependencies
2. Run app: `uvicorn src.main:app --host 0.0.0.0 --port 8000`
3. Open docs: `http://localhost:8000/docs`

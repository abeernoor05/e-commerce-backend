# product-service

Responsibilities:
- Create/list products
- Manage categories
- Track inventory

## Implemented Endpoints
- `GET /health`: service health check
- `POST /products`: create product
- `GET /products`: list products (supports `category` and `in_stock_only` filters)
- `GET /products/{product_id}`: get one product by id
- `PATCH /products/{product_id}/inventory`: set inventory count directly
- `GET /products/{product_id}/availability?quantity=N`: check if stock is enough
- `POST /products/{product_id}/reserve`: reserve stock (used by order-service flow)

## Code Map
- `src/main.py`: app bootstrap, router registration, DB init
- `src/core/config.py`: environment-based settings
- `src/core/database.py`: SQLAlchemy engine/session/base
- `src/models/product.py`: product table model
- `src/schemas/product.py`: request/response models
- `src/api/routes_products.py`: product and inventory handlers

## Local Quick Test
1. Create venv and install dependencies
2. Run app: `uvicorn src.main:app --host 0.0.0.0 --port 8000`
3. Open docs: `http://localhost:8000/docs`

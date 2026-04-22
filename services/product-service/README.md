# product-service

Catalog and inventory microservice for product management.

## Responsibilities

- create and list products
- filter products by category and stock status
- manage inventory quantities
- provide availability and reservation APIs for order-service

## API Endpoints

- GET /health
- POST /products
- GET /products
- GET /products/{product_id}
- PATCH /products/{product_id}/inventory
- GET /products/{product_id}/availability?quantity=N
- POST /products/{product_id}/reserve

## Runtime Configuration

Common environment variables:

- DATABASE_URL
- SERVICE_NAME

## Source Layout

- src/main.py: application bootstrap and middleware setup
- src/api/routes_products.py: product and inventory handlers
- src/core/database.py: SQLAlchemy engine/session wiring
- src/models/product.py: product ORM model
- src/schemas/product.py: request and response schemas

## Local Run

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

Open API docs:

- http://localhost:8000/docs

## Integration Notes

- order-service depends on availability and reserve endpoints
- inventory reservation is synchronous and immediate
- CORS is enabled for browser-based project demo usage

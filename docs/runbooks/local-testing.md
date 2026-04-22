# Local Testing Runbook (Docker Compose)

Use this before any cloud deployment.

## 1. Build and start services

From repository root:

- `docker compose build`
- `docker compose up -d`
- `docker compose ps`

Expected: all three services show `healthy`.

## 2. Health checks

- Auth: `curl http://localhost:8001/health`
- Product: `curl http://localhost:8002/health`
- Order: `curl http://localhost:8003/health`

Expected: each returns status `ok`.

## 3. Auth flow

### Signup

```bash
curl -X POST http://localhost:8001/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123","full_name":"Demo User"}'
```

### Login

```bash
curl -X POST http://localhost:8001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}'
```

Copy `access_token` from response.

### Me

```bash
curl http://localhost:8001/auth/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

## 4. Product flow

### Create product

```bash
curl -X POST http://localhost:8002/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Desk Lamp","description":"LED","category":"home","price":19.99,"inventory_count":6}'
```

Copy returned `id` as `<PRODUCT_ID>`.

### Check availability

```bash
curl "http://localhost:8002/products/<PRODUCT_ID>/availability?quantity=2"
```

## 5. Order flow (calls Product service)

### Create order

```bash
curl -X POST http://localhost:8003/orders \
  -H "Content-Type: application/json" \
  -d '{"product_id":<PRODUCT_ID>,"quantity":2}'
```

### Verify inventory changed

```bash
curl "http://localhost:8002/products/<PRODUCT_ID>/availability?quantity=5"
```

If inventory started at 6 and order quantity is 2, remaining inventory should be 4.

## 6. Stop services

- `docker compose down`

To reset local data volumes:

- `docker compose down -v`

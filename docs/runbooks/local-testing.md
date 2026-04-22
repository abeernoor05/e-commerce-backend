# Local Testing Runbook (Docker Compose)

Use this runbook to validate the full application flow before any cloud deployment.

## Prerequisites

- Docker Engine and Docker Compose plugin installed
- ports 8001, 8002, and 8003 available on local machine

## 1. Start the stack

From repository root:

```bash
docker compose build
docker compose up -d
docker compose ps
```

Expected result:

- auth-service, product-service, and order-service are running
- health status shows healthy after startup delay

## 2. Verify health endpoints

```bash
curl -sS http://localhost:8001/health
curl -sS http://localhost:8002/health
curl -sS http://localhost:8003/health
```

Each endpoint should return JSON containing status: ok.

## 3. Validate authentication flow

Create a user:

```bash
curl -sS -X POST http://localhost:8001/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Passw0rd!","full_name":"Demo User"}'
```

Login and capture token:

```bash
TOKEN=$(curl -sS -X POST http://localhost:8001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Passw0rd!"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
echo "$TOKEN"
```

Fetch current user profile:

```bash
curl -sS http://localhost:8001/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

## 4. Validate product flow

Create a product and capture product ID:

```bash
PRODUCT_ID=$(curl -sS -X POST http://localhost:8002/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Desk Lamp","description":"LED lamp","category":"home","price":19.99,"inventory_count":6}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "$PRODUCT_ID"
```

Check availability:

```bash
curl -sS "http://localhost:8002/products/$PRODUCT_ID/availability?quantity=2"
```

## 5. Validate order flow

Create order:

```bash
curl -sS -X POST http://localhost:8003/orders \
  -H "Content-Type: application/json" \
  -d "{\"product_id\":$PRODUCT_ID,\"quantity\":2}"
```

List orders:

```bash
curl -sS http://localhost:8003/orders
```

Verify inventory was decremented:

```bash
curl -sS "http://localhost:8002/products/$PRODUCT_ID/availability?quantity=5"
```

## 6. Shutdown and cleanup

Stop containers:

```bash
docker compose down
```

Stop containers and delete local persistent volumes:

```bash
docker compose down -v
```

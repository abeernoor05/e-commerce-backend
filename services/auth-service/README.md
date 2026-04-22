# auth-service

Authentication and identity microservice for the e-commerce platform.

## Responsibilities

- user signup
- user login
- JWT generation and validation
- password hashing and credential verification

## API Endpoints

- GET /health
	- service readiness and liveness endpoint
- POST /auth/signup
	- creates a new user record
- POST /auth/login
	- validates credentials and returns access token
- GET /auth/me
	- returns current user using bearer token

## Runtime Configuration

Common environment variables:

- DATABASE_URL
- JWT_SECRET
- JWT_ALGORITHM
- JWT_EXPIRE_MINUTES

## Source Layout

- src/main.py: application bootstrap and middleware setup
- src/api/routes_auth.py: authentication route handlers
- src/core/security.py: hashing and JWT helpers
- src/core/database.py: SQLAlchemy engine/session wiring
- src/models/user.py: user ORM model
- src/schemas/auth.py: request and response schemas

## Local Run

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

Open API docs:

- http://localhost:8000/docs

## Integration Notes

- uses stateless JWT authentication
- designed for external clients and internal service ecosystem
- CORS is enabled for browser-based project demo usage

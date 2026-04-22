# auth-service

Responsibilities:
- Signup
- Login
- JWT token generation/validation
- Password hashing

## Implemented Endpoints
- `GET /health`: service health check
- `POST /auth/signup`: create user with hashed password
- `POST /auth/login`: validate credentials and return JWT
- `GET /auth/me`: return current user from bearer token

## Code Map
- `src/main.py`: app bootstrap, router registration, DB init
- `src/core/config.py`: environment-based settings
- `src/core/database.py`: SQLAlchemy engine/session/base
- `src/core/security.py`: hashing and JWT encode/decode
- `src/models/user.py`: user table model
- `src/schemas/auth.py`: request/response models
- `src/api/routes_auth.py`: auth API handlers

## Local Quick Test
1. Create venv and install dependencies
2. Run app: `uvicorn src.main:app --host 0.0.0.0 --port 8000`
3. Open docs: `http://localhost:8000/docs`

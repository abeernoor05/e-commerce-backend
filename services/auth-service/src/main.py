from fastapi import FastAPI

from src.api.routes_auth import router as auth_router
from src.core.database import Base, engine
from src.models.user import User  # noqa: F401

app = FastAPI(title="auth-service", version="0.1.0")


def init_db() -> None:
    Base.metadata.create_all(bind=engine)


@app.on_event("startup")
def on_startup() -> None:
    init_db()


app.include_router(auth_router)
init_db()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "auth-service"}

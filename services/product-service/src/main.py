from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.routes_products import router as products_router
from src.core.database import Base, engine
from src.models.product import Product  # noqa: F401

app = FastAPI(title="product-service", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def init_db() -> None:
    Base.metadata.create_all(bind=engine)


@app.on_event("startup")
def on_startup() -> None:
    init_db()


app.include_router(products_router)
init_db()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "product-service"}

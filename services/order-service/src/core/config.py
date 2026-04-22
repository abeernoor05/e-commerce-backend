import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./order.db")
PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://localhost:8002")

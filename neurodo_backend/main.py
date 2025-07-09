print("✅ Starting FastAPI App")

from fastapi import FastAPI
from src.core.config import settings
from src.api.v1.router import api_router


from src.core.database import Base, engine


Base.metadata.create_all(bind=engine)


print("✅ Imports successful")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

app.include_router(api_router, prefix=settings.API_V1_STR)

print("✅ FastAPI app created")

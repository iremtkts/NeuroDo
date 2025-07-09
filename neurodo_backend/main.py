from fastapi import FastAPI
from src.core.config import settings
from src.api.v1.router import api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    
)

app.include_router(api_router, prefix=settings.API_V1_STR)
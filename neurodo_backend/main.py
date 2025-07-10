print("✅ Starting FastAPI App")

from fastapi import FastAPI
from src.core.config import settings
from src.api.v1.router import api_router
from src.core.database import Base, engine, SessionLocal
from src.services.category import create_default_categories
from contextlib import asynccontextmanager

print("✅ Imports successful")


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 App is starting... Seeding default categories.")
    db = SessionLocal()
    try:
        create_default_categories(db)
        print("✅ Sistem kategorileri başarıyla oluşturuldu!")
    except Exception as e:
        print(f"❌ Kategori eklenirken hata oluştu: {str(e)}")
    finally:
        db.close()
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan
)


app.include_router(api_router, prefix=settings.API_V1_STR)

print("✅ FastAPI app created")

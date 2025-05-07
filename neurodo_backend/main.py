from fastapi import FastAPI
from database import Base, engine
from auth import router as auth_router
from models import User

app = FastAPI()

# Tabloları yarat
Base.metadata.create_all(bind=engine)

# Router’ları bağla
app.include_router(auth_router, prefix="/auth")

@app.get("/")
async def root():
    return {"message": "NeuroDo API çalışıyor 🚀"}

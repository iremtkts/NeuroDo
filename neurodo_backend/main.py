from fastapi import FastAPI
from database import Base, engine

from models import User

app = FastAPI()

# !!! Bu satır tabloları yaratır
Base.metadata.create_all(bind=engine)

@app.get("/")
async def root():
    return {"message": "NeuroDo API çalışıyor 🚀"}

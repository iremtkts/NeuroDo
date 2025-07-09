from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from src.core.database import get_db
from src.services import category as category_service
from src.schemas.category import Category

router = APIRouter()

@router.get("/", response_model=List[Category])
def get_categories(db: Session = Depends(get_db)):
    """Tüm kategorileri getir"""
    return category_service.get_all_categories(db=db)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.services import ai as ai_service
from src.core.security import get_current_user
from pydantic import BaseModel

router = APIRouter()

class AIMode(BaseModel):
    mode: str

@router.post("/suggest")
def get_suggestions(
    mode: AIMode,
    current_user = Depends(get_current_user)
):
    try:
        suggestions = ai_service.get_ai_suggestions(mode.mode)
        return {"suggestions": suggestions}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI servisi şu anda kullanılamıyor: {str(e)}"
        )
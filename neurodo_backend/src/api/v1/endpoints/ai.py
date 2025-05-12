from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.services import ai as ai_service
from src.core.security import get_current_user
from src.schemas.ai_suggestion import AIMode, AISuggestionSelect
from src.schemas.todo import Todo

router = APIRouter()

@router.post("/suggest")
def get_suggestions(
    mode: AIMode,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        suggestions = ai_service.get_ai_suggestions(
            mode=mode.mode,
            db=db,
            user_id=current_user.id
        )
        return {"suggestions": suggestions}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI servisi şu anda kullanılamıyor: {str(e)}"
        )

@router.post("/select", response_model=Todo)
def select_suggestion(
    suggestion: AISuggestionSelect,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """
    Seçilen AI önerisini kullanıcının todo listesine ekler
    """
    try:
        todo = ai_service.add_suggestion_to_todos(
            suggestion_id=suggestion.suggestion_id,
            db=db,
            user_id=current_user.id
        )
        return todo
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Öneri todo listesine eklenirken bir hata oluştu: {str(e)}"
        )
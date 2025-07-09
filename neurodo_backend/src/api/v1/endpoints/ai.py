from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.responses import JSONResponse
from src.core.database import get_db
from src.services.ai import chat_with_planner, create_todo_from_ai
from src.core.security import get_current_user
from src.schemas.ai import AIChatRequest

router = APIRouter()

@router.post("/chat")
def chat_with_ai(
    request: AIChatRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        user_message = request.message
        ai_response = chat_with_planner(user_message)
        todos = create_todo_from_ai(db, current_user.id, ai_response)

        if not todos:
            raise HTTPException(status_code=400, detail="AI yanıtı uygun formatta değil.")

        response_tasks = [
            {
                "id": todo.id,
                "title": todo.title,
                "description": todo.description,
                "status": todo.status.value,  # Enum'u string olarak döndür
                "category_id": todo.category_id,
                "due_date": str(todo.due_date),
                "due_time": str(todo.due_time)
            }
            for todo in todos
        ]

        return JSONResponse(content={"response": response_tasks})

    except Exception as e:
        print("Hata:", e)
        raise HTTPException(status_code=500, detail="AI yanıtı alınırken veya görev oluşturulurken hata oluştu.")
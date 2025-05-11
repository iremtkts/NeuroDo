from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from src.core.database import get_db
from src.services import todo as todo_service
from src.schemas.todo import Todo, TodoCreate
from src.core.security import get_current_user

router = APIRouter()

@router.get("/", response_model=List[Todo])
def get_todos(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return todo_service.get_user_todos(db=db, user_id=current_user.id)

@router.post("/", response_model=Todo)
def create_todo(
    todo: TodoCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return todo_service.create_todo(db=db, todo=todo, user_id=current_user.id)
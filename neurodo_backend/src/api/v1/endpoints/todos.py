from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date, timedelta, datetime
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

@router.get("/today", response_model=List[Todo])
def get_today_todos(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Bugünün todo'larını getir"""
    return todo_service.get_today_todos(db=db, user_id=current_user.id)

@router.get("/overdue", response_model=List[Todo])
def get_overdue_todos(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Gecikmiş todo'ları getir"""
    return todo_service.get_overdue_todos(db=db, user_id=current_user.id)

@router.get("/upcoming", response_model=List[Todo])
def get_upcoming_todos(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    now = datetime.now()
    one_hour_later = now + timedelta(hours=1)
    todos = db.query(todo_service.Todo).filter(
        todo_service.Todo.user_id == current_user.id,
        todo_service.Todo.due_date.isnot(None),
        todo_service.Todo.due_time.isnot(None)
    ).all()
    upcoming = []
    for todo in todos:
        due_dt = datetime.combine(todo.due_date, todo.due_time)
        if now <= due_dt <= one_hour_later:
            upcoming.append(todo)
    return upcoming

@router.get("/summary", response_model=List[Todo])
def get_summary_todos(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    today = date.today()
    week_later = today + timedelta(days=7)
    week_ago = today - timedelta(days=7)
    return db.query(todo_service.Todo).filter(
        todo_service.Todo.user_id == current_user.id,
        todo_service.Todo.due_date >= week_ago,
        todo_service.Todo.due_date <= week_later
    ).all()

@router.get("/by-date", response_model=List[Todo])
def get_todos_by_date(
    target_date: date = Query(..., description="Hedef tarih (YYYY-MM-DD)"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Belirli bir tarihteki todo'ları getir"""
    return todo_service.get_user_todos_by_date(
        db=db, 
        user_id=current_user.id, 
        target_date=target_date
    )

@router.post("/", response_model=Todo)
def create_todo(
    todo: TodoCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return todo_service.create_todo(db=db, todo=todo, user_id=current_user.id)

@router.put("/{todo_id}", response_model=Todo)
def update_todo(
    todo_id: int,
    todo: TodoCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    updated_todo = todo_service.update_todo(db=db, todo_id=todo_id, todo=todo, user_id=current_user.id)
    if not updated_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return updated_todo

@router.delete("/{todo_id}")
def delete_todo(
    todo_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    deleted_todo = todo_service.delete_todo(db=db, todo_id=todo_id, user_id=current_user.id)
    if not deleted_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return {"message": "Todo deleted successfully"}
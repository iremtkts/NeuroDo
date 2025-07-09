from sqlalchemy.orm import Session
from src.models.todo import Todo
from src.schemas.todo import TodoCreate
from datetime import date, datetime
from typing import List

def get_user_todos(db: Session, user_id: int):
    return db.query(Todo).filter(Todo.user_id == user_id).all()

def get_user_todos_by_date(db: Session, user_id: int, target_date: date):
    """Belirli bir tarihteki todo'ları getir"""
    return db.query(Todo).filter(
        Todo.user_id == user_id,
        Todo.due_date == target_date
    ).all()

def get_user_todos_by_date_range(db: Session, user_id: int, start_date: date, end_date: date):
    """Tarih aralığındaki todo'ları getir"""
    return db.query(Todo).filter(
        Todo.user_id == user_id,
        Todo.due_date >= start_date,
        Todo.due_date <= end_date
    ).all()

def get_today_todos(db: Session, user_id: int):
    """Bugünün todo'larını getir"""
    today = date.today()
    return get_user_todos_by_date(db, user_id, today)

def get_overdue_todos(db: Session, user_id: int):
    """Gecikmiş todo'ları getir"""
    today = date.today()
    return db.query(Todo).filter(
        Todo.user_id == user_id,
        Todo.due_date < today,
        Todo.status == "active"
    ).all()

def create_todo(db: Session, todo: TodoCreate, user_id: int):
    db_todo = Todo(**todo.model_dump(), user_id=user_id)
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

def get_todo(db: Session, todo_id: int, user_id: int):
    return db.query(Todo).filter(Todo.id == todo_id, Todo.user_id == user_id).first()

def update_todo(db: Session, todo_id: int, todo: TodoCreate, user_id: int):
    db_todo = get_todo(db, todo_id, user_id)
    if not db_todo:
        return None
    
    for key, value in todo.model_dump().items():
        setattr(db_todo, key, value)
    
    db.commit()
    db.refresh(db_todo)
    return db_todo

def delete_todo(db: Session, todo_id: int, user_id: int):
    db_todo = get_todo(db, todo_id, user_id)
    if not db_todo:
        return None
    
    db.delete(db_todo)
    db.commit()
    return db_todo
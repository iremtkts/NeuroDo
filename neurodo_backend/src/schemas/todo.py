from pydantic import BaseModel
from datetime import datetime, date, time
from typing import Optional
from .user import User
from .category import Category
from src.models.todo import TodoStatus

class TodoBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: TodoStatus = TodoStatus.ACTIVE
    category_id: Optional[int] = None
    due_date: Optional[date] = None
    due_time: Optional[time] = None

class TodoCreate(TodoBase):
    pass

class Todo(TodoBase):
    id: int
    created_at: datetime
    updated_at: datetime
    due_date: Optional[date] = None
    user_id: int
    user: User
    category: Optional[Category] = None

    class Config:
        from_attributes = True
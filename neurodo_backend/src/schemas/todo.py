from pydantic import BaseModel
from datetime import datetime
from .user import User
from src.models.todo import TodoStatus

class TodoBase(BaseModel):
    title: str
    description: str | None = None
    status: TodoStatus = TodoStatus.ACTIVE

class TodoCreate(TodoBase):
    pass

class Todo(TodoBase):
    id: int
    created_at: datetime
    updated_at: datetime
    user_id: int
    user: User

    class Config:
        from_attributes = True
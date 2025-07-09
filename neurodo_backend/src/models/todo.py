from enum import Enum as PyEnum
class TodoStatus(PyEnum):
    ACTIVE = "active"
    COMPLETED = "completed"
    
from sqlalchemy import Time
from sqlalchemy import Column
from sqlalchemy import Integer, String, Enum, DateTime, Date, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from src.core.database import Base




class Todo(Base):
    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String)
    status = Column(Enum(TodoStatus), default=TodoStatus.ACTIVE)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    due_date = Column(Date, nullable=True)
    due_time = Column(Time, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    
    user = relationship("User", back_populates="todos")
    category = relationship("Category")
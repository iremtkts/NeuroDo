from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from src.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    
    todos = relationship("Todo", back_populates="user")
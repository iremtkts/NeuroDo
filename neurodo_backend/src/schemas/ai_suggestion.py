from pydantic import BaseModel
from datetime import datetime

class AIMode(BaseModel):
    mode: str

class AISuggestionBase(BaseModel):
    suggestion_text: str
    mode: str
    suggestion_index: int

class AISuggestion(AISuggestionBase):
    id: int
    created_at: datetime
    user_id: int

    class Config:
        from_attributes = True

class AISuggestionSelect(BaseModel):
    suggestion_id: int

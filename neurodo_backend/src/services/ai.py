from openai import OpenAI
from src.core.config import settings
from typing import List
from sqlalchemy.orm import Session
from src.models.ai_suggestion import AISuggestion
from src.models.todo import Todo, TodoStatus
from fastapi import HTTPException

client = OpenAI(api_key=settings.OPENAI_API_KEY)

def get_ai_suggestions(mode: str, db: Session, user_id: int) -> List[str]:
    """
    OpenAI API kullanarak kullanıcının moduna göre todo önerileri alır ve veritabanına kaydeder
    """
    prompt = f"""
    Kullanıcı şu anda {mode} modunda. Bu moda uygun 5 adet todo önerisi yap.
    Her öneri kısa ve net olmalı.
    """
    
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "Sen bir üretkenlik asistanısın."},
            {"role": "user", "content": prompt}
        ]
    )
    
    suggestions = response.choices[0].message.content.split('\n')
    suggestions = [s.strip() for s in suggestions if s.strip()]
    
    # Save suggestions to database
    for index, suggestion in enumerate(suggestions):
        db_suggestion = AISuggestion(
            suggestion_text=suggestion,
            mode=mode,
            suggestion_index=index,
            user_id=user_id
        )
        db.add(db_suggestion)
    
    db.commit()
    return suggestions

def add_suggestion_to_todos(suggestion_id: int, db: Session, user_id: int) -> Todo:
    """
    Seçilen AI önerisini kullanıcının todo listesine ekler
    """
    # Öneriyi bul
    suggestion = db.query(AISuggestion).filter(
        AISuggestion.id == suggestion_id,
        AISuggestion.user_id == user_id
    ).first()
    
    if not suggestion:
        raise HTTPException(
            status_code=404,
            detail="Öneri bulunamadı veya bu öneriye erişim izniniz yok"
        )
    
    # Yeni todo oluştur
    new_todo = Todo(
        title=suggestion.suggestion_text,
        status=TodoStatus.ACTIVE,
        user_id=user_id
    )
    
    db.add(new_todo)
    db.commit()
    db.refresh(new_todo)
    
    return new_todo
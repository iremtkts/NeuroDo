from openai import OpenAI
from src.core.config import settings
from typing import List
from sqlalchemy.orm import Session
from src.models.ai_suggestion import AISuggestion
from src.models.todo import Todo, TodoStatus
from fastapi import HTTPException
import re
from datetime import datetime, date, time, timedelta
import json

client = OpenAI(api_key=settings.OPENAI_API_KEY)

def chat_with_planner(user_message: str) -> str:
    today_str = datetime.now().strftime("%Y-%m-%d")
    system_prompt = f"""
Sen bir günlük planlama asistanısın. Bugünün tarihi: {today_str}.
Kullanıcıdan gelen görevleri aşağıdaki JSON formatında döndür:

Her görev için due_time alanını, görevin anlamına uygun ve mantıklı bir saat olarak ata.
Örneğin, sabah yapılacak işler için 08:00-10:00 arası, akşam için 18:00-21:00 arası gibi.

[
  {{
    "title": "Koşuya Çıkma",
    "description": "Güne enerjik başlamak için koşuya çık.",
    "status": "active",
    "category_id": 1,
    "due_date": "{today_str}",
    "due_time": "07:00"
  }},
  {{
    "title": "Yemek Hazırlama",
    "description": "Akşam yemeği için sağlıklı bir öğün hazırla.",
    "status": "active",
    "category_id": 2,
    "due_date": "{today_str}",
    "due_time": "19:00"
  }}
]

Sadece geçerli bir JSON döndür. Açıklama veya başka bir metin ekleme.
"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message}
        ]
    )
    content = response.choices[0].message.content.strip()

    # Sadece JSON array'i yakala: [ { ... } ]
    match = re.search(r"\[\s*{.*}\s*\]", content, re.DOTALL)
    if not match:
        raise ValueError("OpenAI yanıtında geçerli JSON array bulunamadı.")
    
    return match.group(0)

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

def parse_ai_todo_response(ai_response: str):
    """
    AI cevabından başlık, açıklama, gün ve saat gibi bilgileri çıkarır.
    Basit bir örnek: Başlık: ..., Açıklama: ..., Gün: Pazartesi, Saat: 07:00
    """
    # Basit regex ile başlık, açıklama, gün ve saat çekmeye çalış
    title = None
    description = None
    day = None
    hour = None
    minute = 0
    # Başlık
    m = re.search(r"[Bb]aşlık[:：]?\s*(.*)", ai_response)
    if m:
        title = m.group(1).strip()
    # Açıklama
    m = re.search(r"[Aa]çıklama[:：]?\s*(.*)", ai_response)
    if m:
        description = m.group(1).strip()
    # Gün
    m = re.search(r"[Gg]ün[:：]?\s*([\wçğıöşüÇĞİÖŞÜ]+)", ai_response)
    if m:
        day = m.group(1).strip()
    # Saat
    m = re.search(r"[Ss]aat[:：]?\s*(\d{1,2}):(\d{2})", ai_response)
    if m:
        hour = int(m.group(1))
        minute = int(m.group(2))
    return {
        "title": title,
        "description": description,
        "day": day,
        "hour": hour,
        "minute": minute
    }

def create_todo_from_ai(db: Session, user_id: int, ai_response: str):
    import json
    from datetime import datetime

    try:
        todos = json.loads(ai_response)
        created_todos = []
        for todo_data in todos:
            # Tarih ve saat dönüşümü
            due_date = None
            due_time = None
            if todo_data.get("due_date"):
                due_date = date.fromisoformat(todo_data["due_date"])
            if todo_data.get("due_time"):
                due_time = time.fromisoformat(todo_data["due_time"])
            db_todo = Todo(
                title=todo_data["title"],
                description=todo_data.get("description"),
                status=TodoStatus.ACTIVE,
                due_date=due_date,
                due_time=due_time,
                user_id=user_id,
                category_id=todo_data.get("category_id")
            )
            db.add(db_todo)
            db.commit()
            db.refresh(db_todo)
            created_todos.append(db_todo)
        return created_todos
    except Exception as e:
        print("AI cevabı JSON formatında değil veya hata var:", e)
        return None
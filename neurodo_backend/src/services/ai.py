from openai import OpenAI
from src.core.config import settings
from typing import List

client = OpenAI(api_key=settings.OPENAI_API_KEY)

def get_ai_suggestions(mode: str) -> List[str]:
    """
    OpenAI API kullanarak kullanıcının moduna göre todo önerileri alır
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
    return [s.strip() for s in suggestions if s.strip()]
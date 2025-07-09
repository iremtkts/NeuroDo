from src.core.database import SessionLocal
from src.services.category import create_default_categories

def init_categories():
    db = SessionLocal()
    try:
        create_default_categories(db)
        print("✅ Sistem kategorileri başarıyla oluşturuldu!")
    except Exception as e:
        print(f"❌ Hata: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    init_categories()

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Veritabanı bağlantısı
SQLALCHEMY_DATABASE_URL = "sqlite:///./neurodo.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelleri import et
from src.models.user import User
from src.models.todo import Todo

def init_db():
    try:
        # Tabloları oluştur
        Base.metadata.create_all(bind=engine)
        print("✅ Veritabanı tabloları başarıyla oluşturuldu!")
    except Exception as e:
        print(f"❌ Hata: {str(e)}")

if __name__ == "__main__":
    init_db()
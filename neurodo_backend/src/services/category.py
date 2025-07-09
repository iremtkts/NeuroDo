from sqlalchemy.orm import Session
from src.models.category import Category

# Önceden tanımlı kategoriler
DEFAULT_CATEGORIES = [
    "İş", "Kişisel", "Sağlık", "Eğitim", "Ev", 
    "Finans", "Sosyal", "Hobi", "Seyahat", "Teknoloji",
    "Acil", "Önemli", "Rutin", "Proje", "Planlama"
]

def get_all_categories(db: Session):
    """Tüm kategorileri getir"""
    return db.query(Category).all()

def create_default_categories(db: Session):
    """Sistem kategorilerini oluştur"""
    for category_name in DEFAULT_CATEGORIES:
        existing = db.query(Category).filter(Category.name == category_name).first()
        
        if not existing:
            db_category = Category(name=category_name)
            db.add(db_category)
    
    db.commit()

def get_category_by_id(db: Session, category_id: int):
    """ID'ye göre kategori getir"""
    return db.query(Category).filter(Category.id == category_id).first()

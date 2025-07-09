from src.core.database import Base, engine

print("📦 Tablo oluşturma başlıyor...")
Base.metadata.create_all(bind=engine)
print("✅ Tablolar başarıyla oluşturuldu!")

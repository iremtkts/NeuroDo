# Yapay Zeka Destekli Üretkenlik Uygulaması

Bu proje, kullanıcıların ruh haline göre kişiselleştirilmiş görev (to-do) önerileri ve motivasyon mesajları sunan bir **iOS mobil uygulamasıdır**

## Teknolojiler

- **Mobil (iOS):**  
  - Swift, UIKit  
  - SQLite  
  - (Opsiyonel) Firebase Cloud Messaging veya APNs  

- **Backend (Python):**  
  - FastAPI  
  - Pydantic  
  - JWT kütüphanesi (örn. PyJWT)  
  - SQLite 

- **Yapay Zeka:**  
  - OpenAI GPT API (Metin analizi ve öneri üretimi)

---

## Kurulum

### Backend (FastAPI)

1. Python 3.9+ yüklü olduğundan emin olun.  
2. Proje dizinine gelerek sanal ortam oluşturun (isteğe bağlı):  
   ```bash
   python -m venv venv
   source venv/bin/activate


from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.services import auth as auth_service
from src.schemas.user import UserCreate, User
from src.models.user import User as UserModel

router = APIRouter()

@router.post("/signup", response_model=User)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return auth_service.create_user(db=db, user=user)

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return auth_service.authenticate_user(db=db, form_data=form_data)

@router.post("/verify")
def verify_email(email: str, code: str, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    if user.is_verified:
        return {"message": "Zaten doğrulanmış."}
    if user.verification_code != code:
        raise HTTPException(status_code=400, detail="Doğrulama kodu hatalı")
    user.is_verified = 1
    user.verification_code = None
    db.commit()
    return {"message": "E-posta başarıyla doğrulandı."}
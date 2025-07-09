import random
import string
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from src.models.user import User
from src.schemas.user import UserCreate
from src.core.security import get_password_hash, verify_password, create_access_token
from datetime import timedelta
from src.core.config import settings
from src.services.email import send_verification_email

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def create_user(db: Session, user: UserCreate):
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    hashed_password = get_password_hash(user.password)
    # Random 6 haneli doğrulama kodu üret
    verification_code = ''.join(random.choices(string.digits, k=6))
    db_user = User(email=user.email, hashed_password=hashed_password, is_verified=0, verification_code=verification_code)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    # E-posta gönder
    send_verification_email(user.email, verification_code)
    return db_user

def authenticate_user(db: Session, form_data):
    user = get_user_by_email(db, email=form_data.username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="E-posta adresiniz doğrulanmamış. Lütfen e-posta adresinizi doğrulayın.",
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
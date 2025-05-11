from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.services import auth as auth_service
from src.schemas.user import UserCreate, User

router = APIRouter()

@router.post("/signup", response_model=User)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return auth_service.create_user(db=db, user=user)

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return auth_service.authenticate_user(db=db, form_data=form_data)
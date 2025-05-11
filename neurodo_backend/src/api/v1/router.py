from fastapi import APIRouter
from .endpoints import auth, todos, ai

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(todos.router, prefix="/todos", tags=["todos"])
api_router.include_router(ai.router, prefix="/ai", tags=["ai"])
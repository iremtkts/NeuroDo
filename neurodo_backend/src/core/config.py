from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "NeuroDo"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = "sqlite:///./neurodo.db"
    SECRET_KEY: str = "your-secret-key"  # Güvenli bir secret key kullanın
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    OPENAI_API_KEY: str = ""  # OpenAI API anahtarınızı buraya ekleyin

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
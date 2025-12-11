from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

from .core.config import settings
from .core.database import get_db
from .core.security import verify_password, create_access_token, decode_token
from .models import User, UserRole
from .schemas.user import Token, UserResponse

# OAuth2 схема
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")

# Создание приложения
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Dependency для получения текущего пользователя
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """Получение текущего пользователя из токена"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Не удалось проверить учетные данные",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_token(token)
    if payload is None:
        raise credentials_exception
    
    user_id: int = payload.get("sub")
    if user_id is None:
        raise credentials_exception
    
    result = await db.execute(select(User).where(User.user_id == user_id))
    user = result.scalar_one_or_none()
    
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Пользователь неактивен")
    
    return user


# Dependency для проверки роли
def require_role(*allowed_roles: UserRole):
    """Декоратор для проверки роли пользователя"""
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Недостаточно прав для выполнения операции"
            )
        return current_user
    return role_checker


# Корневой endpoint
@app.get("/")
async def root():
    return {
        "message": "Hotel Booking Service API",
        "version": settings.VERSION,
        "docs": "/docs"
    }


# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok"}


# Подключение роутеров
from .api.v1 import auth, users, hotels, rooms, bookings, reviews

app.include_router(auth.router, prefix=settings.API_V1_STR, tags=["auth"])
app.include_router(users.router, prefix=settings.API_V1_STR, tags=["users"])
app.include_router(hotels.router, prefix=settings.API_V1_STR, tags=["hotels"])
app.include_router(rooms.router, prefix=settings.API_V1_STR, tags=["rooms"])
app.include_router(bookings.router, prefix=settings.API_V1_STR, tags=["bookings"])
app.include_router(reviews.router, prefix=settings.API_V1_STR, tags=["reviews"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

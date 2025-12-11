from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from typing import List, Optional
from datetime import datetime
from app.core.database import get_db
from app.models.booking import Review, Booking
from app.models.room import Room
from app.models.user import User
from app.api.dependencies import get_current_user, require_role
from pydantic import BaseModel, Field

# Temporary inline schemas
class ReviewCreateRequest(BaseModel):
    hotel_id: int
    rating: int = Field(ge=1, le=5)
    comment: Optional[str] = None

class ReviewUpdateRequest(BaseModel):
    rating: Optional[int] = Field(None, ge=1, le=5)
    comment: Optional[str] = None

class ReviewResponse(BaseModel):
    review_id: int
    hotel_id: int
    user_id: int
    rating: int
    comment: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True

router = APIRouter(prefix="/reviews")

@router.get("/hotel/{hotel_id}", response_model=List[ReviewResponse])
async def get_hotel_reviews(
    hotel_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Получить все отзывы об отеле"""
    result = await db.execute(
        select(Review)
        .where(Review.hotel_id == hotel_id)
        .order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()
    
    return reviews

@router.get("/{review_id}", response_model=ReviewResponse)
async def get_review(
    review_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Получить конкретный отзыв"""
    result = await db.execute(
        select(Review).where(Review.review_id == review_id)
    )
    review = result.scalar_one_or_none()
    
    if not review:
        raise HTTPException(status_code=404, detail="Отзыв не найден")
    
    return review

@router.post("/", response_model=ReviewResponse)
async def create_review(
    review_data: ReviewCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Создать отзыв (только для гостей, которые останавливались в отеле)"""
    # Проверяем, есть ли у пользователя завершенное бронирование в этом отеле
    booking_check = await db.execute(
        select(Booking)
        .join(Room, Booking.room_id == Room.room_id)
        .where(
            and_(
                Booking.user_id == current_user.user_id,
                Room.hotel_id == review_data.hotel_id,
                Booking.status == 'completed',
                Booking.check_out <= datetime.now().date()
            )
        )
    )
    completed_booking = booking_check.scalar_one_or_none()
    
    if not completed_booking:
        raise HTTPException(
            status_code=403,
            detail="Вы можете оставить отзыв только после проживания в отеле"
        )
    
    # Проверяем, не оставлял ли пользователь уже отзыв
    existing_review_check = await db.execute(
        select(Review).where(
            and_(
                Review.user_id == current_user.user_id,
                Review.hotel_id == review_data.hotel_id
            )
        )
    )
    existing_review = existing_review_check.scalar_one_or_none()
    
    if existing_review:
        raise HTTPException(
            status_code=400,
            detail="Вы уже оставили отзыв об этом отеле"
        )
    
    # Проверяем рейтинг
    if review_data.rating < 1 or review_data.rating > 5:
        raise HTTPException(
            status_code=400,
            detail="Рейтинг должен быть от 1 до 5"
        )
    
    # Создаем отзыв
    new_review = Review(
        user_id=current_user.user_id,
        hotel_id=review_data.hotel_id,
        rating=review_data.rating,
        comment=review_data.comment
    )
    
    db.add(new_review)
    await db.commit()
    await db.refresh(new_review)
    
    return new_review

@router.put("/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: int,
    review_data: ReviewUpdateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Обновить свой отзыв"""
    result = await db.execute(
        select(Review).where(Review.review_id == review_id)
    )
    review = result.scalar_one_or_none()
    
    if not review:
        raise HTTPException(status_code=404, detail="Отзыв не найден")
    
    # Проверяем, что это отзыв текущего пользователя
    if review.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Вы можете редактировать только свои отзывы")
    
    # Обновляем данные
    update_data = review_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(review, field, value)
    
    await db.commit()
    await db.refresh(review)
    
    return review

@router.delete("/{review_id}")
async def delete_review(
    review_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Удалить отзыв"""
    result = await db.execute(
        select(Review).where(Review.review_id == review_id)
    )
    review = result.scalar_one_or_none()
    
    if not review:
        raise HTTPException(status_code=404, detail="Отзыв не найден")
    
    # Проверяем права (пользователь может удалять свои отзывы, админы - любые)
    if review.user_id != current_user.user_id and current_user.role not in ["hotel_admin", "system_admin"]:
        raise HTTPException(status_code=403, detail="Нет доступа к этому отзыву")
    
    await db.delete(review)
    await db.commit()
    
    return {"message": "Отзыв успешно удален"}

@router.get("/my/all", response_model=List[ReviewResponse])
async def get_my_reviews(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Получить все отзывы текущего пользователя"""
    result = await db.execute(
        select(Review)
        .where(Review.user_id == current_user.user_id)
        .order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()
    
    return reviews

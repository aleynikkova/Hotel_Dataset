from pydantic import BaseModel, Field, model_validator, computed_field
from typing import Optional, List, Any
from datetime import datetime
from decimal import Decimal

class RoomTypeBase(BaseModel):
    type_name: str
    description: Optional[str] = None

class RoomTypeResponse(RoomTypeBase):
    room_type_id: int
    
    class Config:
        from_attributes = True

class AmenityBase(BaseModel):
    amenity_name: str

class AmenityResponse(AmenityBase):
    amenity_id: int
    
    class Config:
        from_attributes = True

class RoomBase(BaseModel):
    hotel_id: int
    roomtype_id: int  # Соответствует полю в БД
    room_number: str
    floor: Optional[int] = None
    is_available: bool = True

class RoomCreateRequest(RoomBase):
    amenity_ids: Optional[List[int]] = []

class RoomUpdateRequest(BaseModel):
    roomtype_id: Optional[int] = None
    room_number: Optional[str] = None
    floor: Optional[int] = None
    is_available: Optional[bool] = None
    amenity_ids: Optional[List[int]] = None

class RoomResponse(RoomBase):
    room_id: int
    price_per_night: Optional[float] = None  # Читается из property модели Room
    description: Optional[str] = None  # Читается из property модели Room (из room_type)
    
    class Config:
        from_attributes = True

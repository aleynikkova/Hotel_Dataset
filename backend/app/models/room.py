from sqlalchemy import Column, Integer, String, Text, Numeric, Boolean, ForeignKey, TIMESTAMP, text, Table
from sqlalchemy.orm import relationship
from ..core.database import Base


# Связующая таблица для many-to-many отношения Room-Amenity
room_amenities = Table(
    'room_amenities',
    Base.metadata,
    Column('room_id', Integer, ForeignKey('rooms.room_id', ondelete="CASCADE"), primary_key=True),
    Column('amenity_id', Integer, ForeignKey('amenities.amenity_id', ondelete="CASCADE"), primary_key=True)
)


class RoomType(Base):
    """Модель типа номера"""
    __tablename__ = "roomtypes"
    
    roomtype_id = Column(Integer, primary_key=True, index=True)
    type_name = Column(String(100), nullable=False)
    description = Column(Text)
    price_per_night = Column(Numeric(10, 2), nullable=False)
    
    # Relationships
    rooms = relationship("Room", back_populates="room_type")


class Room(Base):
    """Модель номера"""
    __tablename__ = "rooms"
    
    room_id = Column(Integer, primary_key=True, index=True)
    hotel_id = Column(Integer, ForeignKey("hotels.hotel_id", ondelete="CASCADE"), nullable=False, index=True)
    roomtype_id = Column(Integer, ForeignKey("roomtypes.roomtype_id", ondelete="RESTRICT"), nullable=False)
    room_number = Column(String(10), nullable=False)
    floor = Column(Integer)
    is_available = Column(Boolean, default=True, index=True)
    
    # Relationships
    hotel = relationship("Hotel", back_populates="rooms")
    room_type = relationship("RoomType", back_populates="rooms")
    amenities = relationship("Amenity", secondary=room_amenities, back_populates="rooms")
    bookings = relationship("Booking", back_populates="room")
    
    @property
    def price_per_night(self):
        """Цена берется из типа номера (3NF compliance)"""
        return self.room_type.price_per_night if self.room_type else None
    
    @property
    def description(self):
        """Описание берется из типа номера (3NF compliance)"""
        return self.room_type.description if self.room_type else None


class Amenity(Base):
    """Модель удобства"""
    __tablename__ = "amenities"
    
    amenity_id = Column(Integer, primary_key=True, index=True)
    amenity_name = Column(String(255), nullable=False, unique=True)
    
    # Relationships
    rooms = relationship("Room", secondary=room_amenities, back_populates="amenities")

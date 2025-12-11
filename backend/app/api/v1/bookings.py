from fastapi import APIRouter

router = APIRouter(prefix="/bookings")

@router.get("/")
async def get_bookings():
    return {"message": "Bookings endpoint"}

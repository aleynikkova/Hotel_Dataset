from fastapi import APIRouter

router = APIRouter(prefix="/rooms")

@router.get("/")
async def get_rooms():
    return {"message": "Rooms endpoint"}

from fastapi import APIRouter

router = APIRouter(prefix="/reviews")

@router.get("/")
async def get_reviews():
    return {"message": "Reviews endpoint"}

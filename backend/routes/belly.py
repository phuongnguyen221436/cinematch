from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

# In-memory store (you can keep this)
belly_ratings = {}

# Create a model to accept JSON payloads
class BellyRating(BaseModel):
    user_id: str
    movie_id: int
    score: int

# Accept POST JSON body using the model
@router.post("/belly-rating")
def submit_belly_rating(payload: BellyRating):
    key = (payload.user_id, payload.movie_id)
    belly_ratings[key] = payload.score
    print(f"🍿 Belly rating received: movie {payload.movie_id}, score {payload.score}, user {payload.user_id}")

    return {"status": "success", "score": payload.score}

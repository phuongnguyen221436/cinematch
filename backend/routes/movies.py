from fastapi import APIRouter
from utils.tmdb import get_movies_by_genre

router = APIRouter()

@router.get("/movies")
def fetch_movies(genre: int = 28, rating: float = 7.0):
    movies = get_movies_by_genre(genre_id=genre, min_rating=rating)
    return {"results": movies}

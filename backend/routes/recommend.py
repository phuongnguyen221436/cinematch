from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Movie
from utils.recommend import compute_cosine_similarity, movie_to_vector

router = APIRouter()

# Genre index (same order used across all movie vectors)
GENRE_MAP = {
    "Action": 0, "Romance": 1, "Comedy": 2, "Horror": 3, "Drama": 4, "Sci-Fi": 5
}

# Mood embeddings (optional - for future upgrade)
MOOD_EMBEDDINGS = {
    "chill":      [0.2, 0.8, 0.0, 0.0, 0.0],
    "heartbreak": [0.9, 0.1, 0.0, 0.7, 0.1],
    "thrilling":  [0.0, 0.0, 0.8, 0.5, 0.3],
    "dark":       [0.0, 0.0, 0.6, 0.7, 0.5]
}


# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ✅ Helper: Convert SQLAlchemy model to dict
def sqlalchemy_movie_to_dict(movie):
    return {
        "id": movie.id,
        "title": movie.title,
        "genres": movie.genres or [],
        "vote_average": movie.vote_average or 0,
        "belly_score": movie.belly_score or 5
    }


# ✅ Helper: Human-readable explanation
def generate_reason(target, candidate):
    shared_genres = set(target["genres"]) & set(candidate["genres"])
    reasons = []
    if shared_genres:
        reasons.append(f"Shared genres: {', '.join(shared_genres)}")
    if candidate["belly_score"] > 8:
        reasons.append("High belly score")
    if candidate["vote_average"] > 7.5:
        reasons.append("Critically acclaimed")
    return ", ".join(reasons) if reasons else "Similar profile"

# ✅ Main route
@router.get("/recommendations/{movie_id}")
def recommend_movies(movie_id: int, mood: str = None, db: Session = Depends(get_db)):
    movies_raw = db.query(Movie).all()
    movies = [sqlalchemy_movie_to_dict(m) for m in movies_raw]

    target_movie = next((m for m in movies if m["id"] == movie_id), None)
    if not target_movie:
        return {"error": "Movie not found"}
    
    mood_vector = MOOD_EMBEDDINGS.get(mood.lower()) if mood else None
    target_vec = movie_to_vector(target_movie, GENRE_MAP, mood_vector)
    all_vecs   = [movie_to_vector(m, GENRE_MAP, mood_vector) for m in movies]

    sims = compute_cosine_similarity(target_vec, all_vecs)

    target_vec = movie_to_vector(target_movie, GENRE_MAP)
    all_vecs = [movie_to_vector(m, GENRE_MAP) for m in movies]
    sims = compute_cosine_similarity(target_vec, all_vecs)

    scored = list(zip(movies, sims))
    scored.sort(key=lambda x: x[1], reverse=True)

    top_recs = [
        {
            "id": m["id"],
            "title": m["title"],
            "score": float(score),
            "reason": generate_reason(target_movie, m)
        }
        for m, score in scored if m["id"] != movie_id
    ][:5]

    return {"recommendations": top_recs}

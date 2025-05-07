import requests
import os
from dotenv import load_dotenv

load_dotenv()
TMDB_API_KEY = os.getenv("TMDB_API_KEY")
BASE_URL = "https://api.themoviedb.org/3"

def get_movies_by_genre(genre_id, min_rating=7):
    url = f"{BASE_URL}/discover/movie"
    params = {
        "api_key": TMDB_API_KEY,
        "with_genres": genre_id,
        "vote_average.gte": min_rating,
        "sort_by": "popularity.desc"
    }
    response = requests.get(url, params=params)
    return response.json().get("results", [])

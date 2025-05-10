import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def compute_cosine_similarity(target_vec, all_movie_vecs):
    return cosine_similarity([target_vec], all_movie_vecs)[0]

def movie_to_vector(movie, genre_map, mood_vector=None):
    vector = [0] * len(genre_map)
    for genre in movie["genres"]:
        if genre in genre_map:
            vector[genre_map[genre]] = 1

    rating = movie.get("vote_average", 0) / 10
    belly = movie.get("belly_score", 5) / 10
    vector.extend([rating, belly])
    if mood_vector:
        vector.extend(mood_vector)

    return vector

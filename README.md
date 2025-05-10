# 🎬 CineMatch – Your AI Movie Guide

An iOS + AI-powered app that recommends movies based on your mood, genre, reviews, ratings, and a custom "Belly Ranking" system.

## Features
- Mood-based AI recommendations
- Belly ranking slider system
- Review summarizer using GPT
- TMDb integration


🧠 App Summary:
CineMatch is an iOS app that recommends movies using a personalized AI model trained on genres, IMDb ratings, user preferences, reviews, mood, and watch history. Think of it as “Spotify Discover Weekly” but for movies.

📱 Key Features:
🔍 1. Personalized Movie Recommendations
Ask: “What are you in the mood for today?” (e.g. funny, sad, intense)


Backend uses AI model (collaborative + content-based filtering)


Shows top 5 curated movies with justification (“Recommended because you liked Interstellar”)


🎭 2. Advanced Filters
- Genre (Action, Romance, Horror…)
- Language (English, Korean, French, etc.)
- Streaming platform (Netflix, Prime, Disney+)
- IMDb Rating slider (e.g. 7.5+ only)
- Runtime range (e.g. < 2 hours)


📝 3. Review Summarizer
- Pulls user reviews from IMDb / TMDb
- Uses GPT-based summarization to display:
- “Most viewers found it emotionally powerful, with strong performances but a slow second act.”



🧠 4. AI Mood Picker
- User selects a mood: “chill”, “heartbreak”, “dark thriller”
- App maps that to curated tag embeddings and recommends accordingly


🔄 5. Real-Time Updates
- “New on Netflix” API feed
- Live push updates: “A trending horror film just hit Prime!”


💾 6. Save & Watchlist
- Save favorite movies to personal list
- Optionally sync with Trakt.tv or Letterboxd API


🗣 7. Voice Command Input (Bonus)
- “Recommend me a romantic comedy under 90 minutes”
- Backend converts to filters using NLP



🛠 Tech Stack
Frontend (iOS):
SwiftUI + Combine

- Charts for rating trends


Backend:
- FastAPI or Node.js (Express) REST API
- PostgreSQL (movie meta, user prefs)
- Redis (fast recache for trending queries)
- TMDb API or IMDb datasets as source
- GPT/OpenAI API for summarization
- Custom lightweight movie rec model using cosine similarity + metadata embedding


ML/NLP:
- Content-based filtering using genre, keyword, actor/actress embeddings


- Collaborative filtering (optional based on other user behavior)


- Sentiment + summarization (OpenAI or HuggingFace)


- Keyword → mood → movie tag map


DevOps:
- Docker + Render/Vercel


- Firebase or Supabase for user auth


- GitHub Actions for CI/CD



🧱 Database Schema (Sample)
 Users (id, email, preferences, mood_profile, created_at)
 Movies (id, title, genre[], rating, reviews[], cast, runtime, platform)
 Watchlist (user_id, movie_id, saved_at)
 Interactions (user_id, movie_id, liked, rating, skipped, timestamp)
 Recommendations (user_id, movie_id, reason, timestamp)

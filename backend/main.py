from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import movies
from routes import belly


app = FastAPI()

# Allow frontend to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(movies.router)
app.include_router(belly.router)
@app.get("/")
def read_root():
    return {"message": "CineMatch backend is running"}

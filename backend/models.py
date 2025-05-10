from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.dialects.postgresql import ARRAY
from database import Base

class Movie(Base):
    __tablename__ = "movies"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    genres = Column(ARRAY(String))        # stored as a list of genre strings
    vote_average = Column(Float)
    belly_score = Column(Float)           # optional field you've been tracking

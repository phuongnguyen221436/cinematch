import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load env vars
load_dotenv()

# Read your DATABASE_URL from .env
DATABASE_URL = os.getenv("DATABASE_URL")

# Create the engine
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True  # helps keep connections alive
)

# Session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base class for models
Base = declarative_base()

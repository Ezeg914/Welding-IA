from sqlmodel import create_engine, Session, SQLModel
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

db = create_engine(DATABASE_URL, echo=True)


def init_db():
    SQLModel.metadata.create_all(db)


def get_session():
    with Session(db) as session:
        yield session

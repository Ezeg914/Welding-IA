from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from .imageModel import Image

class Pipe(SQLModel, table=True):
    
    pipe_id: int = Field(primary_key=True)
    name: str = Field(nullable=False)
    comment: Optional[str] = Field(nullable=True)

    images: List[Image] = Relationship(back_populates="pipe")
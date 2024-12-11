from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List


class Image(SQLModel, table=True):
    
    image_id: int = Field(primary_key=True)
    generated_image: str = Field(nullable=False)
    pipe_id: Optional[int] = Field(foreign_key="pipe.pipe_id")
    detection_data: Optional[str] = Field(nullable=True)
    pipe: Optional["Pipe"] = Relationship(back_populates="images")


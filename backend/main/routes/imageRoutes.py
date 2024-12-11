from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from main.models.pipeModel import Pipe
from main.models.imageModel import Image
from main.controllers.pipeController import PipeController
from main.controllers.imageController import ImageController
from db.database import get_session

router = APIRouter()

@router.post("/images/")
def create_image(image: Image, session: Session = Depends(get_session)):
    return ImageController.create_image(image, session)

@router.get("/images/")
def read_images(session: Session = Depends(get_session)):
    return ImageController.read_images(session)

@router.get("/images/{image_id}")
def read_image(image_id: int, session: Session = Depends(get_session)):
    return ImageController.read_image(image_id, session)

@router.delete("/images/{image_id}")
def delete_image(image_id: int, session: Session = Depends(get_session)):
    return ImageController.delete_image(image_id, session)

@router.get("/images/pipe/{pipe_id}")
def get_images_by_pipe_id(pipe_id: int, session: Session = Depends(get_session)):
    images = ImageController.get_images_by_pipe_id(pipe_id, session)
    
    if not images:
        raise HTTPException(status_code=404, detail="No images found for this pipe")
    
    return images
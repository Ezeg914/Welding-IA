from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlmodel import Session
from main.models.pipeModel import Pipe
from main.models.imageModel import Image
from main.controllers.pipeController import PipeController
from main.controllers.imageController import ImageController
from db.database import get_session

router = APIRouter()


@router.post("/pipes/{pipe_id}/images/")
async def process_and_save_image(pipe_id: int, image: UploadFile = File(...), session: Session = Depends(get_session)):
    pipe = PipeController.read_pipe(pipe_id, session)
    if not pipe:
        raise HTTPException(status_code=404, detail="Pipe not found")
    
    image = await PipeController.process_and_save_image(pipe_id, image, session)
    
    return {"message": "Image processed and saved successfully", "image_id": image.image_id}

@router.post("/pipes/")
def create_pipe(pipe: Pipe, session: Session = Depends(get_session)):
    return PipeController.create_pipe(pipe, session)

@router.get("/pipes/")
def read_pipes(session: Session = Depends(get_session)):
    return PipeController.read_pipes(session)

@router.get("/pipes/{pipe_id}")
def read_pipe(pipe_id: int, session: Session = Depends(get_session)):
    return PipeController.read_pipe(pipe_id, session)

@router.put("/pipes/{pipe_id}")
def update_pipe(pipe_id: int, pipe: Pipe, session: Session = Depends(get_session)):
    return PipeController.update_pipe(pipe_id, pipe, session)

@router.delete("/pipes/{pipe_id}")
def delete_pipe(pipe_id: int, session: Session = Depends(get_session)):
    return PipeController.delete_pipe(pipe_id, session)


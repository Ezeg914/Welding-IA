from fastapi import HTTPException, UploadFile
from sqlmodel import Session
from main.models.pipeModel import Pipe
from main.models.imageModel import Image
from main.repositories.pipeRepository import PipeRepository
from main.repositories.imageRepository import ImageRepository
from detector.weldingDetector import analyze_image


class PipeController:

    @staticmethod
    def create_pipe(pipe: Pipe, session: Session):
        return PipeRepository.create_pipe(pipe, session)

    @staticmethod
    async def process_and_save_image(pipe_id: int, image: UploadFile, session: Session):

        image_data = await image.read()

        processed_image_base64 = analyze_image(image_data)
        #print('aca esta bien mostro',processed_image_base64)
        new_image = Image(pipe_id=pipe_id, generated_image=processed_image_base64)
        print('aaaca esta o no esta el error',new_image)
        print('Base64 de la imagen (primeros 50 caracteres):', processed_image_base64[:50])
   
        return ImageRepository.create_image(new_image, session)

    @staticmethod
    def read_pipes(session: Session):
        return PipeRepository.read_pipes(session)

    @staticmethod
    def read_pipe(pipe_id: int, session: Session):
        pipe = PipeRepository.read_pipe(pipe_id, session)
        if pipe:
            return pipe
        raise HTTPException(status_code=404, detail="Pipe not found")

    @staticmethod
    def update_pipe(pipe_id: int, pipe: Pipe, session: Session):
        updated_pipe = PipeRepository.update_pipe(pipe_id, pipe, session)
        if updated_pipe:
            return updated_pipe
        raise HTTPException(status_code=404, detail="Pipe not found")

    @staticmethod
    def delete_pipe(pipe_id: int, session: Session):
        if PipeRepository.delete_pipe(pipe_id, session):
            return {"message": "Pipe deleted successfully"}
        raise HTTPException(status_code=404, detail="Pipe not found")


from fastapi import HTTPException
from sqlmodel import Session
from main.models.pipeModel import Pipe
from main.models.imageModel import Image
from main.repositories.pipeRepository import PipeRepository
from main.repositories.imageRepository import ImageRepository



class ImageController:

    @staticmethod
    def create_image(image: Image, session: Session):
        return ImageRepository.create_image(image, session)

    @staticmethod
    def read_images(session: Session):
        return ImageRepository.read_images(session)

    @staticmethod
    def read_image(image_id: int, session: Session):
        image = ImageRepository.read_image(image_id, session)
        if image:
            return image
        raise HTTPException(status_code=404, detail="Image not found")

    @staticmethod
    def delete_image(image_id: int, session: Session):
        if ImageRepository.delete_image(image_id, session):
            return {"message": "Image deleted successfully"}
        raise HTTPException(status_code=404, detail="Image not found")


    @staticmethod
    def get_images_by_pipe_id(pipe_id: int, session: Session):
        images = ImageRepository.get_images_by_pipe_id(pipe_id, session)
        if images:
            return images
        raise HTTPException(status_code=404, detail="No images found for this pipe")

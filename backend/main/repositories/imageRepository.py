from typing import List
from sqlmodel import Session, select
from main.models.pipeModel import Pipe
from main.models.imageModel import Image



class ImageRepository:
    @staticmethod
    def create_image(image: Image, session: Session):
        #print('aca es ??????',image)
        session.add(image)
        session.commit()
        session.refresh(image)
        return image

    @staticmethod
    def read_images(session: Session):
        return session.exec(select(Image)).all()

    @staticmethod
    def read_image(image_id: int, session: Session):
        return session.get(Image, image_id)

    @staticmethod
    def delete_image(image_id: int, session: Session):
        image = session.get(Image, image_id)
        if image:
            session.delete(image)
            session.commit()
            return True
        return False

    @staticmethod
    def get_images_by_pipe_id(pipe_id: int, session: Session) -> List[Image]:
        statement = select(Image).where(Image.pipe_id == pipe_id)
        return session.exec(statement).all()
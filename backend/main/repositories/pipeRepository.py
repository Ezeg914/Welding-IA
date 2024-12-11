from typing import List
from sqlmodel import Session, select
from main.models.pipeModel import Pipe
from main.models.imageModel import Image
from sqlalchemy.orm import selectinload



class PipeRepository:
    @staticmethod
    def create_pipe(pipe: Pipe, session: Session):
        session.add(pipe)
        session.commit()
        session.refresh(pipe)
        return pipe

    @staticmethod
    def read_pipes(session: Session):
        statement = select(Pipe).options(selectinload(Pipe.images))
        return session.exec(statement).all()

    @staticmethod
    def read_pipe(pipe_id: int, session: Session):
        return session.get(Pipe, pipe_id)

    @staticmethod
    def update_pipe(pipe_id: int, pipe: Pipe, session: Session):
        pipe_db = session.get(Pipe, pipe_id)
        if pipe_db:
            pipe_db.name = pipe.name
            pipe_db.comment = pipe.comment
            session.add(pipe_db)
            session.commit()
            session.refresh(pipe_db)
            return pipe_db
        return None

    @staticmethod
    def delete_pipe(pipe_id: int, session: Session):
        pipe = session.get(Pipe, pipe_id)
        if pipe:
            session.delete(pipe)
            session.commit()
            return True
        return False
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from db.database import init_db
from main.routes import imageRoutes, pipeRoutes

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    init_db()


app.include_router(imageRoutes.router, tags=["Images"], prefix="/api")
app.include_router(pipeRoutes.router, tags=["Pipes"], prefix="/api")

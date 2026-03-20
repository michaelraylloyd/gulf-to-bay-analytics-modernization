print(">>> MAIN.PY LOADED", flush=True)

from dotenv import load_dotenv
load_dotenv()  # <-- loads .env from this folder

from fastapi import FastAPI
from routes import router as equipment_router

app = FastAPI(
    title="Equipment Request API",
    version="1.0.0"
)

app.include_router(equipment_router)

@app.get("/")
async def root():
    return {"status": "ok", "service": "equipment_request_api"}
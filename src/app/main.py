# Auto-detect and handle src directory structure
import sys
from pathlib import Path

if Path(__file__).parent.parent.name == "src":
    sys.path.insert(0, str(Path(__file__).parent.parent))
# End of auto-detect and handle src directory structure

from fastapi import FastAPI

from app.api import router as api_router
from app.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    description="Open API",
    version="0.1.0",
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", tags=["root"])
def read_root():
    return {"message": f"Welcome to {settings.APP_NAME}"}


# This block is for local development
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)

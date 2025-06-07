from fastapi import FastAPI

from app.config import settings
from app.routes.api import router as api_router

app = FastAPI(
    title=settings.APP_NAME,
    description="Open API",
    version=settings.APP_VERSION,
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", tags=["root"])
def read_root() -> dict[str, str]:
    return {"message": f"Welcome to {settings.APP_NAME}"}


# This block is for local development
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)

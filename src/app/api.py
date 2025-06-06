from fastapi import APIRouter
from pydantic import BaseModel


class HealthCheck(BaseModel):
    name: str
    version: str
    status: str


router = APIRouter()


@router.get(
    "/health",
    response_model=HealthCheck,
    tags=["status"],
)
def health_check() -> HealthCheck:
    """
    Health check endpoint.

    Returns basic information about the service status, which is useful for
    load balancers or uptime monitoring.
    """
    return HealthCheck(
        name="fastapi-interview-template",
        version="0.1.0",
        status="OK",
    )

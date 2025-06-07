from fastapi import APIRouter

from app.config import settings
from app.models.health_check import HealthCheck
from app.services.calculate import calculate_sum

router = APIRouter()


@router.get("/health", response_model=HealthCheck, tags=["status"])
def health_check() -> HealthCheck:
    """
    Health check endpoint.

    Returns basic information about the service status, which is useful for
    load balancers or uptime monitoring.
    """
    return HealthCheck(
        name=settings.APP_NAME,
        version=settings.APP_VERSION,
        status="OK",
    )


@router.get("/calculate", response_model=int, tags=["calculate"])
def calculate(a: int, b: int) -> int:
    """
    Calculate the sum of two numbers.
    """
    return calculate_sum(a, b)

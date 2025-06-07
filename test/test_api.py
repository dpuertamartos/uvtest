import pytest
from app.config import settings
from app.main import app
from fastapi.testclient import TestClient


# Fixture that creates the client
# The "scope='module'" means it will be created once per test file
@pytest.fixture(scope="module")
def client() -> TestClient:
    return TestClient(app)


def test_read_root(client: TestClient) -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": f"Welcome to {settings.APP_NAME}"}


def test_health_check(client: TestClient) -> None:
    response = client.get(f"{settings.API_V1_STR}/health")
    assert response.status_code == 200
    json_response = response.json()
    assert json_response["name"] == settings.APP_NAME
    assert json_response["version"] == settings.APP_VERSION
    assert json_response["status"] == "OK"
    assert "version" in json_response


def test_calculate(client: TestClient) -> None:
    response = client.get(f"{settings.API_V1_STR}/calculate?a=1&b=2")
    assert response.status_code == 200
    assert response.json() == 3

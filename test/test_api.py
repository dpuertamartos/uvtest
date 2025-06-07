from app.config import settings
from app.main import app
from fastapi.testclient import TestClient


class TestAPI:
    def setup_class(self):
        self.client = TestClient(app)

    def test_read_root(self):
        response = self.client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": f"Welcome to {settings.APP_NAME}"}

    def test_health_check(self):
        response = self.client.get(f"{settings.API_V1_STR}/health")
        assert response.status_code == 200
        json_response = response.json()
        assert json_response["name"] == "fastapi-template"
        assert json_response["status"] == "OK"
        assert "version" in json_response

    def test_calculate(self):
        response = self.client.get(f"{settings.API_V1_STR}/calculate?a=1&b=2")
        assert response.status_code == 200
        assert response.json() == 3

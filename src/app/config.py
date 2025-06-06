from importlib import metadata

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings, loaded from environment variables or a .env file.

    Talking Point: "Using Pydantic's BaseSettings provides type-safe,
    validated configuration, which prevents many common runtime errors."
    """

    APP_NAME: str = metadata.metadata("uv-template")["Name"]
    APP_VERSION: str = metadata.version("uv-template")
    API_V1_STR: str = "/api/v1"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()

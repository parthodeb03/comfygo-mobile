from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

    PROJECT_NAME: str = "ComfyGo API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    DATABASE_URL: str
    SECRET_KEY: str = Field(min_length=32)
    APP_ENV: str = "development"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:3000"]
    ADMIN_EMAIL: str | None = None
    ADMIN_PASSWORD: str | None = None

    # Auth rate limiting (per IP, sliding window)
    RATE_LIMIT_ENABLED: bool = True
    AUTH_RATE_LIMIT: int = 60          # logins / registers per window
    RESET_RATE_LIMIT: int = 10         # forgot-password / verify-code per window
    RATE_LIMIT_WINDOW_SECONDS: int = 60

    # Password reset codes
    RESET_CODE_TTL_MINUTES: int = 10

    @model_validator(mode="after")
    def require_production_secrets(self):
        if self.APP_ENV.lower() == "production":
            if len(self.SECRET_KEY) < 32:
                raise ValueError("SECRET_KEY must contain at least 32 characters in production")
            if self.DATABASE_URL.startswith("sqlite"):
                raise ValueError("PostgreSQL is required in production")
        return self


settings = Settings()

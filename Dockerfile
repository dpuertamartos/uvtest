# ---- Stage 1: Builder ----
# Build dependencies in a dedicated stage to keep the final image small.
FROM python:3.11-slim AS builder
LABEL stage="builder"

ENV UV_VERSION=0.1.4
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get purge -y --auto-remove curl && rm -rf /var/lib/apt/lists/*
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

RUN uv venv .venv --python 3.11

COPY pyproject.toml ./
RUN uv pip compile pyproject.toml -o requirements.lock

RUN . .venv/bin/activate && uv pip sync --no-cache requirements.lock


# ---- Stage 2: Test Runner ----
# This allows us to run tests in a clean, containerized environment as part of the CI/CD pipeline
FROM builder AS test
LABEL stage="test"

WORKDIR /app

COPY pyproject.toml ./
RUN uv pip compile pyproject.toml --extra dev -o requirements-dev.lock
RUN . .venv/bin/activate && uv pip sync --no-cache requirements-dev.lock

COPY ./src ./src
COPY ./tests ./tests

# The `set -o pipefail` ensures that if the test command fails, the RUN step fails.
RUN . .venv/bin/activate && \
    set -o pipefail && \
    pytest


# ---- Stage 3: Runtime ----
FROM python:3.11-slim AS runtime
LABEL stage="runtime"

# Set environment variables for a non-root user and Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:/home/appuser/.local/bin:${PATH}" \
    HOME=/home/appuser \
    PYTHONPATH=/app/src

WORKDIR /app

# Copy the virtual environment with production dependencies from the builder stage
COPY --from=builder /app/.venv .venv
COPY --chown=appuser:appuser ./src ./src

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
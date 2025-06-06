# ---- Stage 1: Builder ----
# Build dependencies in a dedicated stage to keep the final image small.
FROM python:3.11-slim AS builder
LABEL stage="builder"

# Install uv, the fast Python package manager
ENV UV_VERSION=0.1.4
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get purge -y --auto-remove curl && rm -rf /var/lib/apt/lists/*
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Create a virtual environment
RUN uv venv .venv --python 3.11

# Copy only dependency files to leverage Docker layer caching
COPY pyproject.toml ./
# Generate the lock file inside the container for consistency
RUN uv pip compile pyproject.toml -o requirements.lock

# Install production dependencies into the venv
RUN . .venv/bin/activate && uv pip sync --no-cache requirements.lock


# ---- Stage 2: Test Runner ----
# Talking Point: "I've added a dedicated test stage. This allows us to
# run tests in a clean, containerized environment as part of the CI/CD pipeline,
# ensuring the code works with the production dependencies before creating the final image."
FROM builder AS test
LABEL stage="test"

WORKDIR /app

# We already have the venv from the builder stage. Now install dev dependencies.
COPY pyproject.toml ./
RUN uv pip compile pyproject.toml --extra dev -o requirements-dev.lock
RUN . .venv/bin/activate && uv pip sync --no-cache requirements-dev.lock

# Copy source and test code
COPY ./src ./src
COPY ./tests ./tests

# Run tests
# The `set -o pipefail` ensures that if the test command fails, the RUN step fails.
RUN . .venv/bin/activate && \
    set -o pipefail && \
    pytest


# ---- Stage 3: Runtime ----
# This is the final, slim image that will run in production.
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
# Copy the application source code
COPY --chown=appuser:appuser ./src ./src

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application using Uvicorn
# Talking Point: "The CMD uses uvicorn to run the FastAPI app. I've bound it
# to 0.0.0.0 to make it accessible from outside the container."
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
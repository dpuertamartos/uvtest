# ---- Stage 1: Builder ----
# Use a Python version that matches your pyproject.toml (3.11)
FROM python:3.11-slim AS builder

LABEL stage="uv-builder"

# Set UV_VERSION to pin or leave empty to get latest during build
# ARG UV_VERSION=0.1.38 # Example: Pin to a specific uv version
# RUN echo "Using UV_VERSION: ${UV_VERSION:-latest}"

WORKDIR /opt/uv_installer

# Install uv using the official installer
# Using --no-install-recommends to keep the layer small
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    # If UV_VERSION is set, construct the URL, otherwise use the generic one
    # (Note: The installer script itself doesn't directly take a version arg like this,
    # it usually installs the latest. For specific versions, you'd download the binary directly)
    # For simplicity, we'll use the standard installer which gets the latest stable.
    # If pinning `uv` is critical, you'd download the specific binary for your arch.
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*

# Add uv to PATH. The installer usually puts it in /root/.local/bin for root user.
ENV PATH="/root/.local/bin:${PATH}"

# Set up the application directory
WORKDIR /app

# Create a virtual environment specifically for the application
# Using --seed ensures pip/setuptools are available if uv needs them for any edge cases,
# though uv aims to be self-contained.
RUN uv venv .venv --python 3.11 --seed

# Copy only the necessary files for dependency installation to leverage Docker cache
COPY pyproject.toml requirements.lock ./

# Install production dependencies into the venv using the lock file
# We activate the venv for this RUN command, or prefix uv with .venv/bin/uv
# Using --no-cache for uv pip sync as we want a clean install based on the lock file.
# The main caching benefit for uv comes from its global cache, which isn't relevant inside this ephemeral build stage.
RUN . .venv/bin/activate && \
    uv pip sync --no-cache --strict requirements.lock && \
    # Optional: Clean up uv's own cache if it created any within /root, though unlikely to be large here.
    rm -rf /root/.cache/uv

# ---- Stage 2: Runtime ----
FROM python:3.11-slim AS runtime

LABEL stage="uv-runtime"

# Set environment variables for Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Set the working directory
WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /app/.venv .venv

# Copy the application code
# This should come after copying dependencies to leverage Docker layer caching
COPY main.py .
# If you have other source directories (e.g., a 'src' folder):
# COPY ./src ./src

# Create a non-root user and switch to it for security
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Ensure the Python executable from the venv is on PATH and used
ENV PATH="/app/.venv/bin:${PATH}"

# Command to run your application
CMD ["python", "main.py"]
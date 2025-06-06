# FastAPI Interview Template

This repository serves as a professional, well-structured template for a Python web service. It's designed to showcase best practices in application structure, tooling, testing, and containerization.

### Core Features

-   **FastAPI:** A modern, high-performance web framework for building APIs with automatic, interactive documentation (OpenAPI/Swagger UI).
-   **Pydantic:** For type-safe data validation and settings management.
-   **`uv`:** A fast, modern Python package manager used for dependency resolution and installation.
-   **Ruff:** An extremely fast linter and formatter to ensure code quality and consistency.
-   **Mypy:** Static type checking to catch bugs before runtime.
-   **Pytest:** A robust framework for writing clean and scalable tests.
-   **Docker:** A multi-stage `Dockerfile` for building lean, secure, and testable production images.
-   **Clear Structure:** A `src` layout that separates application code from tests and other project files.

---

## 🚀 Local Development Setup

### Prerequisites

-   Python 3.11+
-   `uv` installed ([`pipx install uv`](https://astral.sh/uv#installation) or `pip install uv`)

### Instructions

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd fastapi-interview-template
    ```

2.  **Create a virtual environment:**
    ```bash
    uv venv
    ```

3.  **Activate the virtual environment:**
    -   macOS / Linux: `source .venv/bin/activate`
    -   Windows: `.venv\Scripts\activate`

4.  **Install dependencies:**
    This project uses lock files for reproducible builds. We'll install development dependencies, which include everything needed for production.
    ```bash
    # First, compile the dev lock file to ensure it's up-to-date
    uv pip compile pyproject.toml --extra dev -o requirements-dev.lock

    # Then, sync the environment with the lock file
    uv pip sync requirements-dev.lock
    ```

---

## 🛠️ Usage

### Running the Application

Once your environment is set up, you can run the API locally:

```bash
uvicorn --app-dir src app.main:app --reload
```

## Commands

1. Format code with Ruff `ruff format .`
2. Lint with Ruff `ruff check .`
3. Run Mypy for static type checking `mypy src`
4. test `pytest`
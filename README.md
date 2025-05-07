# DEV

1. `uv venv .venv -p 3.11`
2. `.\.venv\Scripts\activate`
3. (.venv) `uv pip compile pyproject.toml --extra dev -o requirements-dev.lock`
4. (.venv) `uv pip sync requirements.lock`
5. (.venv) `uv pip sync requirements-dev.lock`
6. (.venv) `python main.py`
7. (.venv) `pytest`

# DOCKER

1. `docker build -t my_uv_project_app .`
2. `docker run --rm my_uv_project_app`
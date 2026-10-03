# ResQVision Command

`resq_command` is the PySide6 desktop command console for operator-side control and monitoring. It is packaged as a Python application using `pyproject.toml`.

## Layout

- `src/resq_command/` — installable Python application package.
- `public/` — fonts, icons, and image resources used by the interface.
- `scripts/` — build, cleanup, and packaging helpers.
- `tests/api/`, `tests/ui/`, `tests/unit/` — API, UI, and unit tests.
- `pyproject.toml` — package metadata, dependencies, console entry point, and test configuration.

## Setup and run

From this folder, create and activate a virtual environment, then install the project in editable mode:

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
resq-command
```

Configure the backend URL and operator settings through the application's configuration before connecting it to a live system. Use `pytest` to run the test suite.
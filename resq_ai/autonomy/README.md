# ResQVision Autonomy AI

This standalone Python project contains the Level 1 flight-safety and telemetry
anomaly model workflow. It trains configured PyTorch models, evaluates their
classification metrics, and exports edge-oriented TFLite and C-header artifacts.
It is an experimental pipeline, not flight-controller firmware, and it is not
currently connected to `resq_flight` or `resq_command`.

## Components

- `configs/flight_safety.yaml` defines telemetry features, windowing, model
	classes, training parameters, and export settings.
- `src/resq_autonomy_ai/data/` handles telemetry normalization and dataset
	windows.
- `src/resq_autonomy_ai/models/` contains the supported safety model
	architectures and registry.
- `src/resq_autonomy_ai/engine/` trains models, saves checkpoints, and computes
	evaluation metrics.
- `src/resq_autonomy_ai/export/` quantizes and exports TFLite and C-array
	artifacts.
- `tests/` contains unit tests for the package.

## Setup

Use Python 3.10 or newer. From this directory, create an isolated environment:

```sh
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

The project uses PyTorch, NumPy, and YAML configuration. Install a PyTorch build
compatible with the target host before training if the default package index
does not provide the needed accelerator build.

## Commands

Run these from `resq_ai/autonomy/`:

```sh
autonomy train
autonomy evaluate --checkpoint checkpoints/best.pth
autonomy export --checkpoint checkpoints/best.pth
```

Each command accepts `--config path/to/flight_safety.yaml`. The default config
uses the project `data/` directory and writes checkpoints to `checkpoints/`;
training currently constructs synthetic telemetry data in code, so results are
for pipeline validation rather than flight use. Replace that data source and
validate on representative, appropriately labeled telemetry before operational
use. Evaluation may write JSON with `--output`; export writes edge artifacts
under `artifacts/` unless another output directory is supplied.

Run tests with:

```sh
pytest
```

Datasets, checkpoints, and generated exports are ignored by Git. Do not interpret
successful training or export as safety certification.

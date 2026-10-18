# ResQVision AI Workspaces

This directory contains two independent machine-learning projects. They have
separate environments, datasets, configurations, outputs, and test suites; the
root README describes how they fit into the larger system.

- [`vision/`](./vision/README.md): Level 2 aerial object detection. Validates
	COCO datasets, trains/evaluates detectors, predicts on images, and exports
	ONNX models.
- [`autonomy/`](./autonomy/README.md): Level 1 flight-safety and telemetry
	anomaly experiments. Trains/evaluates configured models and exports
	quantized TFLite/C-header artifacts. This workflow is not connected to live
	flight hardware.

Do not commit private imagery, datasets, checkpoints, or generated model
artifacts. See the linked project guides for setup, data layouts, commands, and
validation requirements.

# Model Checkpoints

Place trained PyTorch checkpoint files (`.pth`) under a category and task folder.
The backend discovers checkpoint files recursively; no registry entry or frontend
catalog needs to be edited when weights are added.

```text
models/
  human/<task>/<checkpoint>.pth
  trees/<task>/<checkpoint>.pth
  vehicles/<task>/<checkpoint>.pth
  animals/<task>/<checkpoint>.pth
```

Add categories and task folders as needed. Do not commit placeholder or empty
checkpoint files. The checkpoint listing endpoint exposes paths relative to this
directory and does not expose absolute server paths.
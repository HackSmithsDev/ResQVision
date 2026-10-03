# ResQVision Flight Controller

`resq_flight` contains the C firmware-side application organized around the flight-control and hardware support needed by the project. It is intended for the target flight-controller/companion hardware and is separate from the Flutter and cloud applications.

## Layout

- `main.c` — firmware entry point.
- `app/` — application startup, autonomous behavior, communication, core scheduling, flight logic, sensors, drivers, and shared utilities.
- `config/board_fc722.h` — board-specific FC722 configuration.

The repository currently does not include a top-level firmware build/flash manifest. Select and document the exact MCU toolchain, board configuration, and flashing procedure before producing a flight image.

## Safety

Bench-test firmware with propellers removed. Verify failsafe, arming, motor direction, sensor calibration, and emergency-stop behavior before any outdoor or autonomous operation. Do not treat a successful compile as flight certification.
# ResQVision Flight Controller

`resq_flight` documents the DYS FC722 board and its Betaflight integration. The
FC runs Betaflight; this repository does not contain replacement flight-control
firmware and cannot be flashed to the FC as a standalone application.

## Structure

- `docs/fc722-specification.md` — supplied board specifications and hardware
  details that still need confirmation on the physical board.
- `betaflight/README.md` — safe setup, target identification, and configuration
  capture workflow for Betaflight.

The former empty C files were placeholders, not a functioning STM32F7 firmware
project. They are removed to avoid suggesting that this folder builds or
replaces Betaflight. Do not add board pin mappings, a Betaflight target name, or
flashable firmware until those are verified against the exact FC722 revision
and a trusted Betaflight release.

The ELRS receiver connects directly to an FC UART; handset radio control does
not go through `resq_command` or cloud endpoints. The ground station receives
video locally through its HDMI capture card. Native Betaflight MSP ingestion
is not currently implemented in `resq_command`.

## Safety

Use Betaflight Configurator and firmware for the verified board target. Back up
the existing configuration before changing firmware or settings. Bench-test
with propellers removed and verify receiver failsafe, arming, motor direction,
sensor calibration, and emergency-stop behavior. A successful flash or compile
is not flight certification.

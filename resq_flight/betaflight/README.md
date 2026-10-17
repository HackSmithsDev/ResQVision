# Betaflight integration

The FC722 is intended to run Betaflight firmware. This project does not vendor
Betaflight source, define a custom Betaflight target, or currently provide a
flashable image.

## Target and configuration workflow

1. Identify the FC revision and connect Betaflight Configurator over USB.
2. Read and save the board-reported `version`, `status`, and `diff all` output
   before changing settings.
3. Select firmware only after confirming the exact target identifier for this
   board revision with an authoritative Betaflight source.
4. Preserve a reviewed configuration backup with the aircraft's build records.
   Remove personal identifiers or radio bind secrets before sharing it.
5. Bench-test with propellers removed, then verify failsafe and all motor
   outputs before flight.

UART mappings, receiver protocol settings, motor resource mappings, and a
Betaflight target name are intentionally not guessed here. ELRS control remains
a direct receiver-to-flight-controller radio path. Ground-station software and
cloud services do not send control commands to the FC.

## Model artifacts

The autonomy C header and TFLite artifacts are not Betaflight firmware and are
not automatically deployable to the FC722. Any future on-board model
integration requires an explicitly supported execution environment, verified
memory/timing budgets, and a separate safety review.

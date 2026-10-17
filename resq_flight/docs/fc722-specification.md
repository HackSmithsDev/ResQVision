# DYS FC722 board specification

This page records the product specifications supplied for the DYS FC722. They
have not been independently verified against a physical board revision. Treat
board-level details such as UART numbering, pin mapping, and Betaflight target
identifier as unknown until checked on the actual board.

| Item | Supplied specification |
| --- | --- |
| Brand | DYS |
| MCU | Listed as “STM32 FC722”; product description identifies an STM32 F7 |
| Gyroscope | ICM42688P |
| Barometer | BMP280 |
| OSD | AT7456E |
| Blackbox flash | 16 MB |
| UARTs | 6 ports (exact UART numbering and pad mapping not supplied) |
| Motor outputs | 4, SH1.0 connector |
| I2C | SDA and “SLA” pads (label recorded as supplied; verify whether “SLA” means SCL) |
| LED controller | Yes |
| Beeper pad | Yes |
| Firmware | Betaflight |
| Mounting | 30.5 x 30.5 mm pattern; 4 mm PCB holes |
| Board dimensions | 38 x 38 mm |
| Board weight | 10.0 g |
| BEC outputs | 3.3 V / 1 A, 5 V / 3 A, 12 V / 3 A |

The included wire harness and silicon grommets are installation accessories,
not firmware resources. Bluejay is ESC firmware; its mention in the product
description does not identify the FC's Betaflight target.

## Details to establish before flashing

1. Record the exact FC722 hardware revision and confirm the MCU marking.
2. Connect with Betaflight Configurator and capture the existing `version`,
   `status`, and `diff all` CLI output before making changes.
3. Confirm the Betaflight target identifier reported by the board and verify it
   against the intended official firmware release.
4. Confirm UART-to-pad assignments from the board documentation or by careful
   continuity inspection; do not infer them from the six-UART count.
5. Verify voltage/current limits and peripheral connections against the
   manufacturer's board documentation before powering attached equipment.

Do not use a guessed target name, generated board header, or firmware image as a
substitute for these checks.

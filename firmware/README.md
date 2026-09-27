# Firmware

The firmware is a bare-metal 8051 assembly implementation for the Nuvoton W78E052DDG.

## Files

* `digclock.asm` — annotated version prepared for GitHub. The instruction flow is retained, with constants and comments added for readability.
* `archive/digclock\\\_original.asm` — original source preserved as supplied, including the original comments/formatting.

## Main functions

`MAIN`
: Initializes the stack, I/O aliases, Timer0, interrupts, lookup table pointer, clock state, and timer preload.

`ENDLESS`
: Multiplexes the six 7-segment digits and compares the live clock field against the alarm field.

`ISRT0`
: Services Timer0 overflow, builds the approximately one-second software time base, and rolls seconds/minutes/hours.

`MODESELECT`
: Enters the configuration interface through INT0 and selects time-setting or alarm-setting mode.

`SETMODE`
: Handles cursor movement, digit editing, display refresh, and exit from configuration mode.

`TERMINATE`
: Restores the selected representation, restarts Timer0, and returns through the common interrupt-context restoration path.

`RADDX`
: Adds `R4` to `R0`.

`ADDX`
: Adds `R5` to the byte addressed by `R0`.

`DEBOUNCE`
: Implements a simple software delay used after button activity.

## 8051 concepts demonstrated

* fixed reset/interrupt vectors
* `LJMP`, `LCALL`, `RETI`
* Timer0 Mode 1
* external interrupt INT0
* register banks via PSW `RS1:RS0`
* direct and indirect internal-RAM addressing
* `MOVC` table lookup from code memory
* `CJNE` and carry-based unsigned comparison
* software counters and rollover logic
* multiplexed 7-segment display control
* software button debouncing
* two's-complement subtraction via `ADD`

## Timer calculation

```text
Fosc = 11.0592 MHz
12T timer tick = 12 / Fosc
               ≈ 1.085069 µs

Timer0 preload = EFDBH
Counts         = 65536 - EFDBH
               = 4133

One overflow  = 4133 × 1.085069 µs
               ≈ 4.484592 ms

223 overflows = 223 × 4.484592 ms
               ≈ 1.000064 s
```

The calculation is a nominal oscillator/timer calculation. Actual clock accuracy is also affected by the oscillator source and implementation details around interrupt handling and reload timing.

## Toolchain note

The repository does not include the original assembler/project build configuration. The source uses conventional 8051 assembly syntax and should be assembled with a compatible 8051 assembler after verifying any syntax-specific requirements of the chosen toolchain. Do not assume that every assembler accepts every directive or negative-immediate spelling identically.


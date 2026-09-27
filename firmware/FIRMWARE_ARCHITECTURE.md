# Firmware Architecture

## Top-level flow

```text
Reset
  |
  v
MAIN
  |
  +--> initialize Timer0 / interrupts / lookup table
  |
  +--> ENDLESS ----------------------------+
  |      |                                  |
  |      +--> multiplex six displays       |
  |      +--> compare clock vs alarm        |
  |                                         |
  +<-----------------------------------------+

INT0 / MODE button
  |
  v
MODESELECT
  |
  +--> Alarm selected -> copy clock field to alarm field
  |
  +--> Time selected  -> edit live clock field
  |
  v
SETMODE
  |
  +--> LEFT / RIGHT : move selected position
  +--> UP / DOWN     : modify selected value
  +--> display refresh
  +--> MODE          : exit
  |
  v
TERMINATE
  |
  +--> restore representation
  +--> restore saved context
  +--> reload/restart Timer0
  |
  v
RETI

Timer0 overflow
  |
  v
ISRT0
  |
  +--> reload Timer0
  +--> R6++
  +--> every 223 overflows -> advance clock
  +--> seconds -> minutes -> hours rollover
  +--> restore register-bank state
  |
  v
RETI
```

## Display subsystem

All six 7-segment positions share the segment-data bus on P0. The firmware selects one display at a time using P2.7..P2.2.

The display code is looked up from program memory with:

```asm
MOV A, Rn
MOVC A, @A+DPTR
MOV DIGIT, A
```

This is the firmware equivalent of:

```c
pattern = BITPATTERN[index];
P0 = pattern;
```

## Timekeeping subsystem

Timer0 is configured in Mode 1. A 16-bit timer period is generated from the preload `EFDBH`. A software counter in `R6` counts 223 Timer0 overflows before the calendar counters are advanced.

## Alarm subsystem

The live clock field and alarm field are stored separately. The main loop compares six bytes. If all six match, the buzzer is driven high and held for a software delay.

## Configuration subsystem

The MODE button is wired to INT0. The external interrupt is therefore the entry point to the editor. Timer0 is stopped during configuration so the normal timekeeping routine does not continue advancing the clock while values are being edited.

<img width="2448" height="3264" alt="20220314_191802" src="https://github.com/user-attachments/assets/081acf9b-c861-4e0c-8766-332ecf70f025" /># 8051 Digital Clock with Alarm

A bare-metal digital clock and alarm project built around the Nuvoton **W78E052DDG**, an 8051-compatible microcontroller. The project combines firmware, a custom two-layer through-hole PCB, display multiplexing, push-button UI, an audible alarm, and multiple PCB revisions.

## Project highlights

- Nuvoton W78E052DDG 8051-compatible MCU
- 11.0592 MHz clock source
- Six multiplexed 7-segment displays
- Six discrete BC547 digit drivers
- 6-position user interface: LEFT / RIGHT / UP / DOWN / MODE / TIMESET/ALARM selection
- Timer0-driven software time base
- External interrupt 0 used for entering configuration mode
- Alarm time comparison and buzzer output
- 2-layer through-hole PCB developed through multiple revisions
- Final PCB source, schematic, and manufacturing Gerbers included
- Firmware is written in 8051 assembly

## Repository structure

```text
.
├── firmware/
│   ├── digclock.asm
│   ├── MEMORY_MAP.md
│   ├── FIRMWARE_ARCHITECTURE.md
│   ├── README.md
├── hardware/
│   ├── schematic/
│   │   ├── digclock.kicad_sch
│   │   ├── digclock.kicad_pro
│   │   ├── digclock-eagle-import.kicad_sym
│   │   └── sym-lib-table
│   ├── pcb/
│   │   ├── final/
│   │   │   └── digclock.kicad_pcb
│   │   └── revisions/
│   │       ├── v1/digclockv1.kicad_pcb
│   │       ├── v2/digclockv2.kicad_pcb
│   │       ├── v3/digclockv3.kicad_pcb
│   │       └── v4/digclockv4.kicad_pcb
│   ├── fabrication/
│   │   ├── gerbers_final/
│   │   └── historical/
│   │       ├── v2/
│   │       └── v4/
│   ├── README.md
│   └── PCB_DESIGN_HISTORY.md
├── media/
│   └── Digclock_Enclosed.jpg
│   ├── Digclock_PCBA.jpg
│   ├── Digclock_PCB_Unassembled.jpg
│   └── Digclock_Breadboard.jpg
```

## Firmware architecture

The firmware uses two primary interrupts:

- **INT0 / P3.2**: enters the time/alarm setting interface and temporarily stops Timer0.
- **Timer0 overflow**: updates the software clock counters.

The main loop multiplexes the six displays and checks the alarm buffer against the current six-byte clock field.

The software time base uses Timer0 Mode 1 with a reload of **EFDBH**. That corresponds to 4133 timer counts. Assuming the project's 11.0592 MHz oscillator is operated in conventional 12T mode, one overflow is approximately 4.4846 ms and 223 overflows are nominally about 1.000064 s before accounting for exact interrupt/instruction overhead.

## Hardware architecture

The display uses a shared segment bus on **P0** and six digit-select controls on **P2.7 through P2.2**. The digit-select outputs drive six transistor stages so that only one display position is active at a time.

The user-interface and alarm connections are:

| MCU pin | Function |
|---|---|
| P1.0 | LEFT |
| P1.1 | RIGHT |
| P1.2 | UP |
| P1.3 | DOWN |
| P1.4 | BUZZER |
| P2.0 | ALARM mode select |
| P2.1 | TIMESET mode select |
| P3.2 / INT0 | MODE / configuration interrupt |
| P0 | 7-segment segment bus |
| P2.7..P2.2 | Digit select 1..6 |

## PCB development

The repository deliberately keeps the numbered PCB revisions because this was the first PCB project and the revisions document the design process. The revision history is described in `hardware/PCB_DESIGN_HISTORY.md`.

The current manufacturing output is in:

```text
hardware/fabrication/gerbers_final/
```

The final source PCB is:

```text
hardware/pcb/final/digclock.kicad_pcb
```

## Opening the KiCad project

Open `hardware/schematic/digclock.kicad_pro` in KiCad. The PCB can then be opened from the project or directly from `hardware/pcb/final/digclock.kicad_pcb`.

The revision `.kicad_pcb` files are retained as historical snapshots and do not need to be used for the final board.

## Important schematic note

For ease of schematic development and unavailability of the actual IC's symbol, an imported symbol of PIC MCU was used.

Before using the schematic as the starting point for a new design, verify the MCU pin mapping against the **W78E052DDG datasheet** and the final PCB routing.

## Photos / project presentation

Photos of the stage-by-stage progression of this project are uploaded for reference as mentioned below.

1. System wired using a breadboard.
2. PCB fabricated using the final version design but unassembled
3. Components Assembled PCB
4. Assembled PCB enclosed in a 3D-printed Enclosure.

The 3D-printed enclosure was designed by a collaborator.

## Engineering context

This project demonstrates a complete small embedded product workflow:

**requirements → schematic → PCB placement/routing → revision → firmware → bring-up/debug → assembled hardware → enclosure integration**

The firmware is intentionally retained at the assembly level so the implementation details of interrupts, timer configuration, register banks, indirect addressing, table lookup, multiplexing, and bare-metal UI logic remain visible.

## References

- Nuvoton W78E052D / W78E054D datasheet: https://www.nuvoton.com/resource-files/W78E054D_W78E052D_A13.pdf
- KiCad project files: see `hardware/`

## License

No license is asserted by this repository yet.

# 8051 Digital Clock & Alarm

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
│   ├── digclock.asm                 # Annotated portfolio version
│   ├── README.md
│   └── archive/
│       └── digclock_original.asm    # Original source preserved unchanged
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
├── docs/
│   ├── FIRMWARE_ARCHITECTURE.md
│   ├── MEMORY_MAP.md
│   ├── GITHUB_UPLOAD_GUIDE.md
│   └── DESIGN_NOTES.md
├── media/
│   └── README.md
└── .gitignore
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

The archived KiCad schematic contains an imported MCU symbol whose **library ID is `MCU:PIC16F877A-I_P` while the value field is `W78E052DDG`**. This appears to be an artifact of the original symbol/import workflow. The repository intentionally preserves the original design files rather than rewriting their historical content.

Before using the schematic as the starting point for a new design, verify the MCU pin mapping against the **W78E052DDG datasheet** and the final PCB routing.

## Photos / project presentation

The `media/` directory is reserved for:

1. bare PCB photographs,
2. assembled PCB photographs,
3. enclosed product photographs, and
4. optional PCB renders/screenshots.

The 3D-printed enclosure was designed by a collaborator; the repository should credit that contribution separately rather than representing the enclosure as the author's PCB design.

## Quick start for GitHub

The fastest way to publish this project is to upload the repository root as-is. The detailed command-line procedure is in `docs/GITHUB_UPLOAD_GUIDE.md`.

For a portfolio reviewer, start with:

1. `README.md` — project overview and architecture
2. `firmware/digclock.asm` — annotated embedded implementation
3. `hardware/pcb/final/digclock.kicad_pcb` — final board source
4. `hardware/PCB_DESIGN_HISTORY.md` — PCB revision story
5. `media/` — add your photographs here

## Engineering context

This project demonstrates a complete small embedded product workflow:

**requirements → schematic → PCB placement/routing → revision → firmware → bring-up/debug → assembled hardware → enclosure integration**

The firmware is intentionally retained at the assembly level so the implementation details of interrupts, timer configuration, register banks, indirect addressing, table lookup, multiplexing, and bare-metal UI logic remain visible.

## References

- Nuvoton W78E052D / W78E054D datasheet: https://www.nuvoton.com/resource-files/W78E054D_W78E052D_A13.pdf
- KiCad project files: see `hardware/`

## License

No license is asserted by this repository yet. Add a license before accepting external contributions or permitting reuse.

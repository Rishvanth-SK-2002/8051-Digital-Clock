# Hardware / PCB

The hardware is a two-layer, through-hole digital clock and alarm board designed in KiCad.

## Source files

The final design consists of:

* schematic: `schematic/digclock.kicad\_sch`
* KiCad project: `schematic/digclock.kicad\_pro`
* final PCB layout: `pcb/final/digclock.kicad\_pcb`
* historical PCB revisions: `pcb/revisions/v1` through `v4`
* final fabrication outputs: `fabrication/gerbers\_final`

## Final PCB

The final PCB file in this repository is approximately **97 mm × 67 mm**.

The project uses through-hole components including the MCU, 7-segment displays, BC547 transistor stages, resistors, capacitors, crystal, regulator, switches, buzzer, and battery connector.

## Revision files

The numbered revisions are retained as design-history snapshots. See `PCB\_DESIGN\_HISTORY.md` for the evolution details.

## Fabrication

The `gerbers\_final` directory contains the final Gerber and drill outputs supplied with the project. These are the files to inspect with a Gerber viewer before sending a board to fabrication.

Do not edit Gerbers manually to modify the electrical design. Make changes in the KiCad schematic/PCB source, run design-rule checks, and regenerate fabrication outputs.

## Reusing the design

Before manufacturing another batch:

1. Open the final project in KiCad.
2. Verify the schematic-to-PCB consistency.
3. Run ERC/DRC using the rules appropriate for the intended manufacturer.
4. Inspect Edge.Cuts, drill files, silkscreen, and all copper layers in a Gerber viewer.
5. Confirm the W78E052DDG pin mapping.
6. Confirm component availability and footprints.
7. Generate a fresh fabrication package from the final PCB rather than relying on historical Gerbers.


# PCB Design History

The repository contains several layouts because this was the first PCB design and the board went through multiple physical revisions.

The electrical component inventory is essentially consistent across the numbered layouts, so the revisions appear to focus primarily on placement, routing, board dimensions, and mechanical refinement rather than a fundamental circuit redesign.

## Revision dimensions and routing density

| Revision | Board size | Routed segments in file* | Interpretation |
|---|---:|---:|---|
| V1 | 130 × 95 mm | 392 | Initial large-board implementation |
| V2 | 94 × 66 mm | 470 | Major size reduction and routing optimization |
| V3 | 113.03 × 66 mm | 41 | Intermediate layout experiment / incomplete routing snapshot |
| V4 | 102 × 70 mm | 497 | Further placement/mechanical refinement |
| Final | 97 × 67 mm | 470 | Compact final layout with mounting-hole refinement |

\* Segment counts are derived from the KiCad PCB files and are included as an objective file-level comparison, not as a measure of PCB quality.

## Inferred development story

### V1

The first board is substantially larger than the later designs. The component inventory is already close to the eventual product architecture, suggesting this was primarily a first physical implementation of the working circuit.

### V2

The board area drops by roughly half relative to V1. The component placement is more compact and the PCB contains a fully routed layout. This is consistent with an optimization pass focused on reducing board size while retaining the same circuit.

### V3

The board is wider than V2, but the file contains only 41 routed segments. That strongly suggests an intermediate placement/routing experiment rather than a final manufacturing candidate.

### V4

The board returns to a more compact form and includes a more deliberate mechanical arrangement. The historical file also includes mounting-hole geometry, indicating that physical integration was becoming an explicit design constraint.

### Final

The final board is approximately 97 × 67 mm and includes mounting holes. Its placement/routing characteristics are close to the compact V2 family rather than the wider V4 arrangement, which is consistent with returning to a favorable earlier placement strategy and then making final mechanical/routing refinements.

These interpretations are intentionally marked as **inferences from the supplied CAD files**. The exact reason for each revision should ultimately be described using the designer's own notes/photos when available.

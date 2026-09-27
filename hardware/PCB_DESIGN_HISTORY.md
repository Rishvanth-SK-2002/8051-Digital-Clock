# PCB Design History

The repository contains several layouts because this was my first PCB design and the board went through multiple physical revisions.

The electrical component inventory is the same across all the versions as the revisions focus primarily on placement, routing, board dimensions, and mechanical refinement rather than fundamental circuit redesigns.

## Revision dimensions and routing density

| Revision | Board size | Routed segments in file* | Interpretation |
|---|---:|---:|---|
| V1 | 130 × 95 mm | 392 | Initial large-board implementation |
| V2 | 94 × 66 mm | 470 | Major size reduction and routing optimization |
| V3 | 113.03 × 66 mm | 41 | Intermediate layout experiment / incomplete routing snapshot |
| V4 | 102 × 70 mm | 497 | Further placement/mechanical refinement |
| Final | 97 × 67 mm | 470 | Compact final layout with mounting-hole refinement |

\* Routed segment counts are included as an objective file-level comparison, not as a measure of PCB quality.

## Development story

### V1

This was the first physical implementation of the working circuit, ensuring the component placements and fully traced layouts, but with no regard to spacing constraints. Trace width was about 10 mils.

### V2

This was a try at achieving a more compact form factor than the first version, decreasing the trace widths to 7.84 mils, placing the components closer and routing with the traces and pads dangerously close to each other.

### V3

This version is an incomplete one. Continued and completed in version 4.

### V4

Trace widths increased to 20 mils due to a locally available manufacturer's constraints then. Mounting holes were added before finalizing the enclosure design.

### Final

The final board is approximately 97 × 67 mm and comes back to 7.84 mil traces. It is very similar to version 2 but with mounting holes and few other minor refinements in the tracing.


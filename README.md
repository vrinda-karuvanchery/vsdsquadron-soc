# VSDSquadron SoC: RTL-to-GDS, GLS, and Signoff Portfolio

This repository is a portfolio-grade record of my work in the VSD Squadron Physical Design Program, covering RTL-to-GDSII implementation, gate-level simulation, and post-route signoff using open-source ASIC tools on SkyWater 130nm.

It is structured to show not just the final result, but the engineering trail behind it: RTL sources, integration trees, verification collateral, OpenROAD configuration, gate-level validation, screenshots, and week-by-week technical documentation.

## Snapshot

- Program: VSD Squadron Physical Design Program
- Timeline: Feb 2026 - Mar 2026
- Focus: RTL-to-GDS, Gate-Level Simulation, STA, DRC, and physical signoff
- Platform: SkyWater 130nm
- Environment: GitHub Codespaces and local Ubuntu

## Highlighted Outcomes

- Executed end-to-end RTL-to-GDSII of the PicoRV32a RISC-V core on SkyWater 130nm using open-source tools.
- Completed synthesis, floorplan, placement, CTS, detailed routing, post-route STA, and ECO-driven timing closure.
- Achieved:
  - `fmax = 152 MHz`
  - `WNS = +0.18 ns`
  - `DRC = 0 violations`
  - `Power = 24.1 mW`
  - `Area = 61,097 um^2`
- Independently brought up the VSDSquadron SoC `user_project_wrapper` through the OpenROAD flow at `100 MHz`.
- Resolved RTL hierarchy and dependency issues across the Caravel and management-SoC integration trees.
- Performed Gate-Level Simulation for standalone and Caravel-integrated testcases to validate RTL-to-netlist functional continuity.
- Performed post-route signoff checks including OpenSTA timing review, PDN inspection, and DRC/antenna verification through KLayout-oriented deliverables.

## What This Repository Contains

This repo combines three kinds of material:

1. Design and platform source trees
2. Verification and GLS collateral
3. Week-wise engineering documentation

Together, they show the full chip-implementation story rather than only final screenshots or reports.

## Repository Structure

### Core source trees

- [`caravel/`](./caravel)
  - Caravel platform RTL used for top-level integration, clocking, housekeeping, IO, reset, and pad-level behavior.
- [`caravel_mgmt_soc_litex/`](./caravel_mgmt_soc_litex)
  - Management SoC RTL, firmware support, include files, VIP models, and design-verification testbenches.
- [`vsdcaravel/`](./vsdcaravel)
  - VSD-specific Caravel variant used during this effort.
- [`vsdcaravel_mgmt_soc_litex/`](./vsdcaravel_mgmt_soc_litex)
  - VSD-specific management-SoC variant with modified test and integration collateral.

### Documentation and implementation logs

- [`week3-documentation/`](./week3-documentation)
  - Standalone verification bring-up and SPI debug notes.
- [`Week4/`](./Week4)
  - OpenROAD flow setup and backend execution for `user_project_wrapper`.
- [`Week5/`](./Week5)
  - Gate-Level Simulation work, Caravel integration debug, and Makefile/runtime fixes.
- [`Week6/`](./Week6)
  - Independent block implementation and GLS work for `housekeeping_spi`.

### Supporting evidence

- [`screenshots/`](./screenshots)
  - Screenshots used inside the documentation to show logs, reports, flow completion, and debug checkpoints.

## What This Repo Demonstrates

### 1. RTL-to-GDS implementation

This repo documents practical backend implementation work using:

- Yosys for synthesis
- OpenROAD-flow-scripts for physical implementation
- TritonCTS for clock-tree synthesis
- OpenSTA for timing analysis
- KLayout-oriented signoff checks and deliverable review

The implementation work includes:

- resolving design hierarchy and dependencies
- preparing ORFS configuration
- writing and tuning SDC constraints
- floorplan sizing and density tuning
- stage-wise backend execution from synthesis through finish
- timing-closure and ECO-oriented iteration

### 2. Gate-Level Simulation

The repo also captures GLS work for both:

- standalone SoC block-level tests
- full Caravel-integrated tests

The GLS effort includes:

- selecting and wiring synthesized netlists into the simulation flow
- fixing stale Makefile paths and firmware build assumptions
- restoring proper VexRiscv startup and linker flows
- debugging reset, clock, boot, flash, and checkpoint visibility issues
- validating results using waveform inspection and testbench checkpoints

### 3. Signoff-oriented validation

This repo includes evidence and notes around:

- post-route timing review
- DRC and antenna closure
- PDN/topology inspection
- LEF, DEF, and GDS deliverable verification

## Recommended Reading Order

If you want the quickest way to understand the work, read these in order:

1. [`Week4/README.md`](./Week4/README.md)  
   OpenROAD bring-up and physical-design execution for `user_project_wrapper`
2. [`Week5/README.md`](./Week5/README.md)  
   Gate-level simulation repair, Caravel integration debug, and validation status
3. [`Week6/README.md`](./Week6/README.md)  
   Independent RTL-to-GDS and GLS work for the `housekeeping_spi` block
4. [`week3-documentation/README.md`](./week3-documentation/README.md)  
   Earlier verification/debug journey and standalone test bring-up

## Key Technical Areas Reflected In This Repo

- RTL hierarchy analysis
- Caravel-based SoC integration
- OpenROAD-flow-scripts configuration
- synthesis-to-route execution
- STA and timing closure
- GLS setup and debug
- firmware/testbench co-debug
- waveform-based failure isolation
- signoff review and final deliverable validation

## Why This Repo Is Structured This Way

This is intentionally not a minimal or cleaned-down demo repo.

Collaborators and reviewers can see:

- the original RTL context
- the integration environment
- the verification collateral
- the implementation setup
- the debug path taken to get results
- the written engineering reasoning behind each phase

That makes this repository useful as both:

- a technical portfolio
- a traceable engineering notebook

## Author

**Vrinda Karuvanchery**  
VLSI Physical Design Engineer  
Portfolio: https://vrinda-karuvanchery.github.io/aboutme/

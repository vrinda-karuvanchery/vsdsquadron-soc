# Week 4 - OpenROAD Flow for `user_project_wrapper`

This section documents the OpenROAD-flow-scripts (ORFS) bring-up and backend execution for the `user_project_wrapper` design on the `sky130hd` platform. The work was done in a Codespace and the key configuration files used for the run are stored in this repository.

## 1. Design dependency analysis

### Design RTL inputs

The Week 4 RTL sources tracked in this repository are:

- [`rtl/__user_project_wrapper.v`](./rtl/__user_project_wrapper.v)
- [`rtl/debug_regs.v`](./rtl/debug_regs.v)
- [`rtl/defines.v`](./rtl/defines.v)

### ORFS design dependencies

The ORFS run depended on:

- Design config: [`configs/config.mk`](./configs/config.mk)
- Clock constraints: [`configs/constraint.sdc`](./configs/constraint.sdc)
- Platform: `sky130hd`
- Liberty file: `sky130_fd_sc_hd__tt_025C_1v80.lib`
- LEF files: `sky130_fd_sc_hd.tlef` and `sky130_fd_sc_hd_merged.lef`

### Notes on design bring-up

- Yosys initially failed because `__user_project_wrapper.v` uses the macro `` `MPRJ_IO_PADS ``.
- The working fix was to pass the define explicitly through ORFS:
  - `export VERILOG_DEFINES += -DMPRJ_IO_PADS=38`
- Floorplan also needed a larger die/core area because the wrapper has a high IO count and the default die perimeter was not sufficient for IO placement.

## 2. ORFS configuration notes

The working ORFS configuration is stored in [`configs/config.mk`](./configs/config.mk). The key settings used were:

```make
export DESIGN_NAME = user_project_wrapper
export DESIGN_NICKNAME = user_project_wrapper
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export PLACE_DENSITY = 0.55
export VERILOG_DEFINES += -DMPRJ_IO_PADS=38
export DIE_AREA = 0 0 2200 2200
export CORE_AREA = 10 10 2190 2190
```

Configuration rationale:

- `VERILOG_DEFINES` was required to resolve the `MPRJ_IO_PADS` macro during synthesis.
- `DIE_AREA` and `CORE_AREA` were set explicitly to avoid IO placement failure caused by insufficient die perimeter.
- `PLACE_DENSITY = 0.55` was used as a moderate starting point.

## 3. Directory structure used

### Repository structure for this submission

```text
Week4/
├── README.md
├── configs/
│   ├── config.mk
│   └── constraint.sdc
├── docs/
│   └── openroad_flow_notes.md
└── rtl/
    ├── __user_project_wrapper.v
    ├── debug_regs.v
    └── defines.v
```

### ORFS runtime structure used during the run

```text
OpenROAD-flow-scripts/flow/
├── designs/sky130hd/user_project_wrapper/
├── designs/src/user_project_wrapper/
├── results/sky130hd/user_project_wrapper/base/
├── logs/sky130hd/user_project_wrapper/base/
├── reports/sky130hd/user_project_wrapper/base/
└── objects/sky130hd/user_project_wrapper/base/
```

## 4. Clock constraint configuration

The clock constraint is stored in [`configs/constraint.sdc`](./configs/constraint.sdc):

```tcl
create_clock -name wb_clk -period 10 [get_ports {wb_clk_i}]
```

This sets a 10 ns clock period for the Wishbone clock input `wb_clk_i`.

## 5. Execution steps

The ORFS run was executed from the `flow/` directory of the OpenROAD-flow-scripts checkout.

```bash
cd /workspaces/OpenROAD-flow-scripts/flow

make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk synth
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk floorplan
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk place
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk cts
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk route
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk finish
```

## 6. Stage-wise screenshots and logs

### 6.1 Synthesis

Synthesis completed successfully and generated `1_synth.odb` and `1_synth.sdc`.

Evidence:

![Synthesis completion](../screenshots/Screenshot%202026-03-29%20at%206.52.51%20PM.png)

Main stage log:

- `logs/sky130hd/user_project_wrapper/base/1_1_yosys_canonicalize.log`
- `logs/sky130hd/user_project_wrapper/base/1_synth.log`

### 6.2 Floorplan

Floorplan completed successfully after switching from utilization-based floorplan initialization to explicit `DIE_AREA` and `CORE_AREA`.

Observed floorplan metric:

- Design area: `6482 um^2`
- Utilization: `0%` in the floorplan report because the die was intentionally expanded to satisfy the wrapper IO perimeter requirement

Evidence:

![Floorplan stages](../screenshots/Screenshot%202026-03-29%20at%206.59.57%20PM.png)

![Floorplan final report](../screenshots/Screenshot%202026-03-29%20at%208.15.36%20PM.png)

Main stage logs:

- `logs/sky130hd/user_project_wrapper/base/2_1_floorplan.log`
- `logs/sky130hd/user_project_wrapper/base/2_2_floorplan_macro.log`
- `logs/sky130hd/user_project_wrapper/base/2_3_floorplan_tapcell.log`
- `logs/sky130hd/user_project_wrapper/base/2_4_floorplan_pdn.log`

### 6.3 Placement and IO placement

Placement proceeded successfully after the floorplan area was increased. IO placement was a key checkpoint because the design has `637` top-level IOs.

Evidence:

![IO placement success](../screenshots/Screenshot%202026-03-29%20at%208.21.36%20PM.png)

Placement/resizer summary:

- Design area after placement resize: `85015 um^2`
- Utilization: `2%`
- Floating nets warning observed: `2 floating nets`

Evidence:

![Placement resize summary](../screenshots/Screenshot%202026-03-29%20at%208.23.03%20PM.png)

Main stage logs:

- `logs/sky130hd/user_project_wrapper/base/3_1_place_gp_skip_io.log`
- `logs/sky130hd/user_project_wrapper/base/3_2_place_iop.log`
- `logs/sky130hd/user_project_wrapper/base/3_3_place_gp.log`
- `logs/sky130hd/user_project_wrapper/base/3_4_place_resized.log`

### 6.4 CTS

CTS completed successfully with no setup or hold violations reported in the shown summary.

Evidence:

![CTS summary](../screenshots/Screenshot%202026-03-29%20at%208.24.46%20PM.png)

Observed CTS metrics:

- Design area: `85381 um^2`
- Utilization: `2%`
- No setup violations found
- No hold violations found

Main stage log:

- `logs/sky130hd/user_project_wrapper/base/4_1_cts.log`

### 6.5 Route

Detailed routing reported intermediate violations during iterative repair, but these were fully resolved by the end of the route stage.

Evidence:

![Detailed route violations converging to zero](../screenshots/Screenshot%202026-03-29%20at%208.35.24%20PM.png)

Final route observations:

- Final detailed-route violations: `0`
- Antenna net violations: `0`
- Antenna pin violations: `0`

Main stage logs:

- `logs/sky130hd/user_project_wrapper/base/5_1_grt.log`
- `logs/sky130hd/user_project_wrapper/base/5_2_route.log`
- `logs/sky130hd/user_project_wrapper/base/5_3_fillcell.log`

### 6.6 Finish

The finish stage completed and generated the final handoff files.

Finish-stage summary evidence:

![Finish report summary](../screenshots/Screenshot%202026-03-29%20at%208.39.51%20PM.png)

Observed finish metrics:

- Design area: `85388 um^2`
- Utilization: `2%`
- RC extraction completed
- Power and IR-drop summary generated

Main stage log:

- `logs/sky130hd/user_project_wrapper/base/6_report.log`

## 7. Final output artifacts

The final result directory contained the expected handoff artifacts, including GDS, DEF, ODB, netlist, SDC, and SPEF.

Evidence:

![Final output artifacts in results directory](../screenshots/Screenshot%202026-03-29%20at%208.49.11%20PM.png)

Key final artifacts:

- `results/sky130hd/user_project_wrapper/base/6_final.gds`
- `results/sky130hd/user_project_wrapper/base/6_final.def`
- `results/sky130hd/user_project_wrapper/base/6_final.odb`
- `results/sky130hd/user_project_wrapper/base/6_final.v`
- `results/sky130hd/user_project_wrapper/base/6_final.sdc`
- `results/sky130hd/user_project_wrapper/base/6_final.spef`

## 8. Debugging notes

### Issue 1: Missing Yosys binary

Initial ORFS synthesis failed because the local checkout did not yet have the expected tool installation under `tools/install/`.

Resolution:

- Ran dependency setup and local OpenROAD build
- Verified `openroad` and `yosys` were installed before rerunning synthesis

### Issue 2: Undefined Verilog macro `MPRJ_IO_PADS`

Yosys failed while parsing `__user_project_wrapper.v` because `MPRJ_IO_PADS` was not defined.

Resolution:

- Added `export VERILOG_DEFINES += -DMPRJ_IO_PADS=38` to the design config

### Issue 3: IO placement failure due to insufficient die perimeter

The original floorplan failed because the number of IO pins exceeded the available pin locations on the die perimeter.

Resolution:

- Switched to explicit floorplan geometry
- Used:
  - `DIE_AREA = 0 0 2200 2200`
  - `CORE_AREA = 10 10 2190 2190`

### Issue 4: Intermediate routing violations

Detailed route initially reported many violations during iterative refinement.

Resolution:

- Tracked the route log across iterations
- Confirmed that the detailed router converged to `0` final violations
- Confirmed antenna checks also ended with `0` violations

## 9. Supporting notes

Additional short-form notes from the ORFS bring-up are stored in:

- [`docs/openroad_flow_notes.md`](./docs/openroad_flow_notes.md)

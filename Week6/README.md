# Week 6 - Independent Block Implementation and Gate-Level Validation

This document captures the complete OpenROAD-based RTL-to-GDS implementation work completed for the `housekeeping_spi` block from the VSDSquadron SoC repository. The work was performed in GitHub Codespaces using the `sky130hd` platform in OpenROAD-flow-scripts (ORFS).

## 1. Block Selection

### Selected block

- Block: `housekeeping_spi`
- RTL source: [`caravel/verilog/rtl/housekeeping_spi.v`](../caravel/verilog/rtl/housekeeping_spi.v)

### Why this block was selected

- It is a real standalone RTL module under the required Caravel RTL path.
- It has a clean top module and a compact interface.
- It is small enough to complete the full RTL-to-GDS flow independently.
- It still represents meaningful chip logic: command decoding, address/data shifting, read/write strobes, and pass-through control for housekeeping SPI.

### Top module and interface summary

- Top module: `housekeeping_spi`
- Clock: `SCK`
- Reset: `reset`
- Main SPI interface:
  - `SCK`
  - `SDI`
  - `CSB`
  - `SDO`
- Functional outputs:
  - `odata`
  - `oaddr`
  - `rdstb`
  - `wrstb`
  - `pass_thru_mgmt`
  - `pass_thru_user`
  - delay/reset pass-through control signals

### Internal functionality summary

The block implements a compact SPI-controlled housekeeping interface. It receives serial command, address, and data fields, decodes them through a small FSM, drives read/write strobes, and supports management/user pass-through modes. The major internal states visible in the RTL are:

- `COMMAND`
- `ADDRESS`
- `DATA`
- `MGMTPASS`
- `USERPASS`

### RTL dependency setup

For this independent block run, the implementation dependency list was intentionally kept minimal:

- [`caravel/verilog/rtl/housekeeping_spi.v`](../caravel/verilog/rtl/housekeeping_spi.v)

Unlike larger wrapper-level runs, this block did not require a multi-file RTL bundle for synthesis in ORFS.

## 2. ORFS Bring-Up in Codespace

The OpenROAD backend run was executed from:

```bash
/workspaces/OpenROAD-flow-scripts/flow
```

### ORFS source and design folders created

```text
/workspaces/OpenROAD-flow-scripts/flow/designs/src/housekeeping_spi
/workspaces/OpenROAD-flow-scripts/flow/designs/sky130hd/housekeeping_spi
```

### RTL copied into the ORFS source tree

```text
/workspaces/OpenROAD-flow-scripts/flow/designs/src/housekeeping_spi/housekeeping_spi.v
```

## 3. ORFS Configuration

The ORFS design configuration used for this block is:

### `config.mk`

Location:

```text
/workspaces/OpenROAD-flow-scripts/flow/designs/sky130hd/housekeeping_spi/config.mk
```

Contents:

```make
export DESIGN_NAME = housekeeping_spi
export DESIGN_NICKNAME = housekeeping_spi
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION = 35
export PLACE_DENSITY = 0.45
```

Configuration notes:

- `DESIGN_NAME` and `DESIGN_NICKNAME` both point to `housekeeping_spi`.
- `VERILOG_FILES` picks up the RTL copied into the ORFS source folder.
- `CORE_UTILIZATION = 35` was used as a conservative starting point for this small standard-cell block.
- `PLACE_DENSITY = 0.45` provided routability headroom during placement.

### `constraint.sdc`

Location:

```text
/workspaces/OpenROAD-flow-scripts/flow/designs/sky130hd/housekeeping_spi/constraint.sdc
```

Contents:

```tcl
create_clock -name hkspi_clk -period 10 [get_ports {SCK}]
```

Constraint notes:

- The block clock is `SCK`.
- A 10 ns period was used, corresponding to a 100 MHz target frequency.

## 4. OpenROAD Execution Flow

The backend flow was run stage by stage:

```bash
cd /workspaces/OpenROAD-flow-scripts/flow

make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk synth
make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk floorplan
make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk place
make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk cts
make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk route
make DESIGN_CONFIG=./designs/sky130hd/housekeeping_spi/config.mk finish
```

## 5. Stage-by-Stage Results

### 5.1 Synthesis

Key synthesis outputs:

- `1_2_yosys.v`
- `1_synth.odb`
- `synth_stat.txt`
- `synth_check.txt`

Observed synthesis metrics:

- Cell count: `237`
- Synthesized area: `2376.0288 um^2`
- Structural check result: `Found and reported 0 problems`

Evidence source files:

- `/workspaces/OpenROAD-flow-scripts/flow/reports/sky130hd/housekeeping_spi/base/synth_stat.txt`
- `/workspaces/OpenROAD-flow-scripts/flow/reports/sky130hd/housekeeping_spi/base/synth_check.txt`

### 5.2 Floorplan

Important floorplan metrics were extracted from:

- `/workspaces/OpenROAD-flow-scripts/flow/logs/sky130hd/housekeeping_spi/base/2_1_floorplan.log`
- `/workspaces/OpenROAD-flow-scripts/flow/logs/sky130hd/housekeeping_spi/base/2_1_floorplan.json`

Observed floorplan values:

- Die bounding box: `(0.000, 0.000) to (84.395, 84.395) um`
- Core bounding box: `(1.380, 2.720) to (83.260, 81.600) um`
- Die area: `7122.52 um^2`
- Core area: `6458.69 um^2`
- Instance area: `2376.03 um^2`
- Effective utilization: `0.368`
- Reported design utilization: `37%`

Floorplan observations:

- The floorplan was generated successfully from utilization-based sizing.
- No floorplan errors were reported.
- The resulting utilization left enough room for placement and routing.

### 5.3 Placement

Relevant placement reports:

- `3_global_place.rpt`
- `3_detailed_place.rpt`
- `3_resizer.rpt`

Relevant placement logs:

- `3_3_place_gp.log`
- `3_4_place_resized.log`
- `3_5_place_dp.log`

Key placement/routability observations:

- Total routing overflow: `0.0000`
- Overflowed tiles: `0 (0.00%)`
- Average top `0.5%` routing congestion: `0.8176`
- Average top `1.0%` routing congestion: `0.7944`
- Average top `2.0%` routing congestion: `0.7844`
- Average top `5.0%` routing congestion: `0.7537`
- Routability final weighted congestion: `0.8085`

Interpretation:

- Global placement converged successfully.
- No routing overflow remained after placement optimization.
- Congestion stayed below the routing target, indicating a healthy placement for subsequent CTS and routing.

### 5.4 Clock Tree Synthesis

Relevant report:

- `4_cts_final.rpt`

Observed CTS timing values:

- `tns max = 0.00`
- `wns max = 0.00`
- Worst slack: `3.33`
- `hkspi_clk period_min = 2.19`
- Estimated `fmax = 456.96 MHz`
- Setup skew: `-0.06`

CTS observations:

- Clock tree insertion completed successfully.
- The design remained timing clean after CTS.
- No setup or hold failures were observed in the CTS report.

### 5.5 Routing

Relevant route files:

- `5_global_route.rpt`
- `5_route_drc.rpt`
- `5_1_grt.log`
- `5_2_route.log`
- `5_3_fillcell.log`

Global route summary:

- Reported design area: `2927 um^2`
- Post-route utilization: `45%`
- No setup violations
- No hold violations
- No max slew violations
- No max fanout violations
- No max capacitance violations

Detailed route summary:

- Routing initially showed intermediate DRC violations during iterative repair.
- The final iteration converged to `0` violations.
- Final route DRC report file is empty, which indicates no remaining final DRC markers.

Final route observations from `5_2_route.log`:

- `Completing 100% with 0 violations`
- `Number of violations = 0`
- `Found 0 antenna violations`
- `Found 0 net violations`
- `Found 0 pin violations`
- Total wire length: `5146 um`
- Total number of vias: `1839`

Interpretation:

- The route stage completed successfully.
- Intermediate detailed-route DRC snapshots were resolved by the end of routing.
- Final routing is clean and antenna-safe.

### 5.6 Finish

Relevant final report:

- `6_finish.rpt`

Final timing summary:

- `tns max = 0.00`
- `wns max = 0.00`
- Worst slack: `3.34`
- `hkspi_clk period_min = 2.18`
- Estimated `fmax = 459.03 MHz`
- Max slew violation count: `0`
- Max fanout violation count: `0`
- Max cap violation count: `0`
- Setup violation count: `0`
- Hold violation count: `0`

Final power summary:

- Internal power: `2.59e-04 W`
- Switching power: `7.08e-05 W`
- Leakage power: `1.31e-09 W`
- Total power: `3.30e-04 W`

Final interpretation:

- The block met the 100 MHz target comfortably.
- Final signoff-style timing checks stayed clean.
- Final power remained low, as expected for a compact SPI controller block.

## 6. Final Implementation Outputs

The ORFS run produced the required implementation handoff files under:

```text
/workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/housekeeping_spi/base
```

Key final outputs:

- Synthesized netlist: `1_2_yosys.v`
- Post-route/final netlist: `6_final.v`
- Final DEF: `6_final.def`
- Final ODB: `6_final.odb`
- Filled database: `6_1_fill.odb`
- Final SPEF: `6_final.spef`
- Final SDC: `6_final.sdc`
- Final GDSII: `6_final.gds`
- Merged GDS: `6_1_merged.gds`

## 7. Repository and Runtime Paths Used

### Week 6 documentation area

```text
/workspaces/vsdsquadron-soc/Week6
```

### ORFS design setup

```text
/workspaces/OpenROAD-flow-scripts/flow/designs/src/housekeeping_spi
/workspaces/OpenROAD-flow-scripts/flow/designs/sky130hd/housekeeping_spi
```

### ORFS runtime output area

```text
/workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/housekeeping_spi/base
/workspaces/OpenROAD-flow-scripts/flow/reports/sky130hd/housekeeping_spi/base
/workspaces/OpenROAD-flow-scripts/flow/logs/sky130hd/housekeeping_spi/base
```

## 8. Image Evidence

The following screenshots were captured during the Week 6 run and are stored under [`Week6/images`](./images). They document the OpenROAD bring-up in Codespaces and can be used as evidence in the final submission.

### Representative flow screenshots

![Run screenshot 1](./images/Screenshot%202026-04-06%20at%2010.19.15%20PM.png)
![Run screenshot 2](./images/Screenshot%202026-04-06%20at%2010.22.45%20PM.png)
![Run screenshot 3](./images/Screenshot%202026-04-06%20at%2010.23.51%20PM.png)
![Run screenshot 4](./images/Screenshot%202026-04-06%20at%2010.24.03%20PM.png)
![Run screenshot 5](./images/Screenshot%202026-04-06%20at%2010.25.05%20PM.png)
![Run screenshot 6](./images/Screenshot%202026-04-06%20at%2010.25.39%20PM.png)

### Additional backend screenshots

![Run screenshot 7](./images/Screenshot%202026-04-06%20at%2010.26.13%20PM.png)
![Run screenshot 8](./images/Screenshot%202026-04-06%20at%2010.26.45%20PM.png)
![Run screenshot 9](./images/Screenshot%202026-04-06%20at%2010.26.57%20PM.png)
![Run screenshot 10](./images/Screenshot%202026-04-06%20at%2010.27.09%20PM.png)
![Run screenshot 11](./images/Screenshot%202026-04-06%20at%2010.31.07%20PM.png)
![Run screenshot 12](./images/Screenshot%202026-04-06%20at%2010.31.29%20PM.png)

### Late-stage implementation screenshots

![Run screenshot 13](./images/Screenshot%202026-04-06%20at%2010.35.43%20PM.png)
![Run screenshot 14](./images/Screenshot%202026-04-06%20at%2010.43.49%20PM.png)
![Run screenshot 15](./images/Screenshot%202026-04-06%20at%2010.44.00%20PM.png)
![Run screenshot 16](./images/Screenshot%202026-04-06%20at%2010.45.05%20PM.png)
![Run screenshot 17](./images/Screenshot%202026-04-06%20at%2010.46.12%20PM.png)
![Run screenshot 18](./images/Screenshot%202026-04-06%20at%2010.46.22%20PM.png)
![Run screenshot 19](./images/Screenshot%202026-04-06%20at%2010.46.32%20PM.png)
![Run screenshot 20](./images/Screenshot%202026-04-06%20at%2010.49.19%20PM.png)
![Run screenshot 21](./images/Screenshot%202026-04-06%20at%2010.53.37%20PM.png)
![Run screenshot 22](./images/Screenshot%202026-04-06%20at%2010.59.45%20PM.png)
![Run screenshot 23](./images/Screenshot%202026-04-06%20at%2011.01.08%20PM.png)
![Run screenshot 24](./images/Screenshot%202026-04-06%20at%2011.02.38%20PM.png)
![Run screenshot 25](./images/Screenshot%202026-04-06%20at%2011.02.47%20PM.png)
![Run screenshot 26](./images/Screenshot%202026-04-06%20at%2011.02.54%20PM.png)

## 9. Current Status

`housekeeping_spi` has successfully completed the full ORFS implementation path:

- RTL selection and setup
- ORFS design creation
- Synthesis
- Floorplan
- Placement
- CTS
- Routing
- Finish
- Final netlist, DEF, ODB, and GDS generation

The next Week 6 step outside this README is gate-level simulation and waveform validation using the generated implementation netlist.

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

Evidence:

![ORFS design setup for `housekeeping_spi` in the OpenROAD flow workspace.](./images/Screenshot%202026-04-06%20at%2010.19.15%20PM.png)
![Creation of the `sky130hd/housekeeping_spi` design configuration directory in ORFS.](./images/Screenshot%202026-04-06%20at%2010.22.45%20PM.png)
![`housekeeping_spi.v` copied into the ORFS source tree for synthesis and backend flow.](./images/Screenshot%202026-04-06%20at%2010.23.51%20PM.png)
![Week 6 OpenROAD configuration setup showing the dedicated design folders for the selected block.](./images/Screenshot%202026-04-06%20at%2010.24.03%20PM.png)

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

Evidence:

![`config.mk` prepared for the `housekeeping_spi` OpenROAD run.](./images/Screenshot%202026-04-06%20at%2010.25.05%20PM.png)
![`constraint.sdc` created with a 100 MHz clock on port `SCK`.](./images/Screenshot%202026-04-06%20at%2010.25.39%20PM.png)

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

Evidence:

![Start of synthesis for `housekeeping_spi` using ORFS.](./images/Screenshot%202026-04-06%20at%2010.26.13%20PM.png)
![Synthesis stage generating the gate-level netlist and synthesis database.](./images/Screenshot%202026-04-06%20at%2010.26.45%20PM.png)
![Synthesis completion with generated netlist `1_2_yosys.v`.](./images/Screenshot%202026-04-06%20at%2010.26.57%20PM.png)
![Synthesis reports showing cell count, area, and clean structural check.](./images/Screenshot%202026-04-06%20at%2010.27.09%20PM.png)

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

Evidence:

![Floorplan stage initialization for `housekeeping_spi`.](./images/Screenshot%202026-04-06%20at%2010.31.07%20PM.png)
![Floorplan completion showing die/core creation and initial utilization.](./images/Screenshot%202026-04-06%20at%2010.31.29%20PM.png)

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

Evidence:

![Placement stage execution for the selected block.](./images/Screenshot%202026-04-06%20at%2010.35.43%20PM.png)
![Global placement convergence with routability-driven optimization enabled.](./images/Screenshot%202026-04-06%20at%2010.43.49%20PM.png)
![Placement result showing zero routing overflow and acceptable congestion.](./images/Screenshot%202026-04-06%20at%2010.44.00%20PM.png)
![Detailed placement and legalization completed successfully.](./images/Screenshot%202026-04-06%20at%2010.45.05%20PM.png)

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

Evidence:

![CTS stage execution for `housekeeping_spi`.](./images/Screenshot%202026-04-06%20at%2010.46.12%20PM.png)
![Clock tree synthesis completed with clean timing and inserted clock buffers.](./images/Screenshot%202026-04-06%20at%2010.46.22%20PM.png)
![CTS timing summary showing no setup or hold violations.](./images/Screenshot%202026-04-06%20at%2010.46.32%20PM.png)

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

Evidence:

![Global routing stage started for the implemented block.](./images/Screenshot%202026-04-06%20at%2010.49.19%20PM.png)
![Detailed routing progress showing iterative DRC repair during route optimization.](./images/Screenshot%202026-04-06%20at%2010.53.37%20PM.png)
![Final routing completion with zero remaining route violations.](./images/Screenshot%202026-04-06%20at%2010.59.45%20PM.png)
![Antenna check and final route cleanup completed successfully.](./images/Screenshot%202026-04-06%20at%2011.01.08%20PM.png)

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

Evidence:

![Finish stage generating final implementation outputs.](./images/Screenshot%202026-04-06%20at%2011.02.38%20PM.png)
![Final OpenROAD handoff files generated, including DEF, ODB, netlist, and GDS.](./images/Screenshot%202026-04-06%20at%2011.02.47%20PM.png)
![Final implementation summary showing successful completion of RTL-to-GDS for `housekeeping_spi`.](./images/Screenshot%202026-04-06%20at%2011.02.54%20PM.png)

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

## 8. Gate-Level Simulation

Standalone block-level GLS was performed using the synthesized gate-level netlist generated by ORFS:

- Synthesized GLS netlist: `/workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/housekeeping_spi/base/1_2_yosys.v`
- GLS testbench: [`gls/hkspi_gl_tb.v`](./gls/hkspi_gl_tb.v)

The testbench was first validated against the RTL version of [`housekeeping_spi.v`](../caravel/verilog/rtl/housekeeping_spi.v), and then the same stimulus was applied to the synthesized gate-level netlist.

### RTL sanity simulation

```bash
cd /workspaces/vsdsquadron-soc
iverilog -g2012 -o /tmp/hkspi_rtl.vvp \
  /workspaces/vsdsquadron-soc/Week6/gls/hkspi_gl_tb.v \
  /workspaces/vsdsquadron-soc/caravel/verilog/rtl/housekeeping_spi.v && \
vvp /tmp/hkspi_rtl.vvp
```

Observed result:

- `PASS: housekeeping_spi direct testbench completed`

### Synthesized GLS command

```bash
cd /workspaces/vsdsquadron-soc
iverilog -g2012 -DFUNCTIONAL -DGL -DUNIT_DELAY='#1' -o /tmp/hkspi_gl_synth.vvp \
  /workspaces/vsdsquadron-soc/Week6/gls/hkspi_gl_tb.v \
  /workspaces/OpenROAD-flow-scripts/tools/OpenROAD/src/sta/examples/sky130_hd_primitives.v \
  /workspaces/OpenROAD-flow-scripts/tools/OpenROAD/src/sta/examples/sky130_hd.v \
  /workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/housekeeping_spi/base/1_2_yosys.v && \
vvp /tmp/hkspi_gl_synth.vvp
```

Observed GLS result:

- `PASS: housekeeping_spi direct testbench completed`

### GLS interpretation

This pass result means:

- the synthesized post-synthesis gate-level netlist compiled correctly
- the gate-level simulation executed successfully
- the expected SPI read, write, and pass-through behaviors were preserved
- the tested synthesized behavior matched the RTL intent for the exercised scenarios

Therefore, for the current Week 6 validation scope:

- RTL simulation passed
- Post-synthesis GLS passed
- Functional correctness was preserved between RTL and synthesized gate-level implementation for the tested cases

### GLS evidence

The simulation also generated a VCD waveform dump:

- `hkspi_gl.vcd`

This waveform was opened in GTKWave for gate-level signal inspection.

Evidence:

![Post-synthesis gate-level simulation pass for `housekeeping_spi` using the generated synthesized netlist.](./images/Screenshot%202026-04-06%20at%2011.42.18%20PM.png)

### Waveform validation

The generated `hkspi_gl.vcd` waveform was inspected in GTKWave to confirm that the gate-level activity matched the expected SPI transaction behavior.

Key signals reviewed:

- `SCK`
- `CSB`
- `SDI`
- `SDO`
- `oaddr[7:0]`
- `wrstb`
- `pass_thru_mgmt`
- `pass_thru_user`

Waveform observations:

- `CSB` goes low during active transactions and returns high at the end of each SPI transfer.
- `SCK` toggles throughout the command/address/data phases, confirming the expected serial clock activity at gate level.
- `SDI` changes with the applied SPI command stream, while `SDO` shows gate-level serial readback behavior during the read transaction.
- `wrstb` pulses during the write transaction, confirming correct write-command decoding in GLS.
- `pass_thru_mgmt` and `pass_thru_user` assert for their respective command patterns, matching the intended control decode behavior from the RTL.

Waveform evidence:

![GTKWave view of the `housekeeping_spi` post-synthesis GLS waveform showing SPI activity and key control signals.](./images/Screenshot%202026-04-09%20at%2011.08.26%20PM.png)

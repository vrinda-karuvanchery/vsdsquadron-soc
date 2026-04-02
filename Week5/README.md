# Week 5

## Gate-Level Simulation (GLS) for Full Block Verification

This week focused on replacing the RTL `__user_project_wrapper` used in Week 3 with the synthesized gate-level netlist generated in the OpenROAD flow, updating the standalone verification Makefiles, and re-running standalone tests in `SIM=GL` mode.

## Netlist used

- GLS netlist chosen: `/workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/user_project_wrapper/base/1_2_yosys.v`
- Why this netlist was chosen:
  - `6_final.v` was available, but it required a much larger set of post-route cells and fill cells that were not available in the reduced local PDK simulation models.
  - `1_2_yosys.v` is the synthesized gate-level netlist and was a better fit for the available GLS setup.

![OpenROAD result folder showing available netlists](../screenshots/Screenshot%202026-04-01%20at%205.35.11%20PM.png)

## Shared GLS debugging work

The first part of the work was not test-specific. The shared standalone GLS flow had to be repaired before individual blocks could run.

### 1. Path fixes

The original standalone Makefiles pointed to `/home/vsduser`, but the actual workspace used in this project is `/workspaces/vsdsquadron-soc`. The following path-related variables were updated in the modified standalone Makefiles:

- `DESIGNS ?= /workspaces/vsdsquadron-soc`
- `PDK_ROOT ?= /workspaces/vsdsquadron-soc/.ciel`
- `GCC_PATH ?= /usr/bin`

### 2. CPU flag fix for newer RISC-V toolchain

The startup assembly uses CSR instructions such as `csrw`, so the CPU flags had to be updated to include `zicsr`.

Old:

```make
CPUFLAGS_vexriscv := -march=rv32i -mabi=ilp32 -D__vexriscv__
CPUFLAGS_picorv32 := -march=rv32i -mabi=ilp32
CPUFLAGS_ibex     := -march=rv32i -mabi=ilp32
```

New:

```make
CPUFLAGS_vexriscv := -march=rv32i_zicsr -mabi=ilp32 -D__vexriscv__
CPUFLAGS_picorv32 := -march=rv32i_zicsr -mabi=ilp32
CPUFLAGS_ibex     := -march=rv32i_zicsr -mabi=ilp32
```

### 3. GLS netlist integration

Each GLS-enabled standalone Makefile was updated to use a dedicated variable:

```make
export GLS_NETLIST ?= /workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/user_project_wrapper/base/1_2_yosys.v
```

This replaced the older hardcoded GL wrapper path:

```make
$(CARAVEL_PATH)/gl/__user_project_wrapper.v
```

### 4. Early netlist existence check

A `check-gl` target was added to fail early if the gate-level netlist path was wrong:

```make
check-gl:
	@test -f "$(GLS_NETLIST)" || (echo "ERROR: Missing GLS netlist: $(GLS_NETLIST)"; exit 1)
```

The simulation build dependency was changed from:

```make
%.vvp: %_tb.v %.hex
```

to:

```make
%.vvp: %_tb.v %.hex check-gl
```

### 5. Shared GLS include-file fixes

The shared standalone GLS file list at [includes.gl.standalone](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/includes/includes.gl.standalone) also needed updates:

- `mgmt_core.v` was taken from RTL because `gl/mgmt_core.v` did not exist.
- `RAM128.v` and `RAM256.v` were explicitly added from RTL.
- missing `DFFRAM` and missing SRAM model references were commented out.
- the reduced local HD cell models were replaced with the fuller OpenROAD example files:
  - `/workspaces/OpenROAD-flow-scripts/tools/OpenROAD/src/sta/examples/sky130_hd_primitives.v`
  - `/workspaces/OpenROAD-flow-scripts/tools/OpenROAD/src/sta/examples/sky130_hd.v`
- duplicate `sky130_ef_io.v` inclusion had to be disabled because it conflicted with the OpenROAD example primitives.

## Step-by-step Makefile changes

### `spi_master/Makefile`

File: [spi_master/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-standalone/spi_master/Makefile)

Applied changes:

1. Updated `DESIGNS` to `/workspaces/vsdsquadron-soc`.
2. Updated `PDK_ROOT` to `/workspaces/vsdsquadron-soc/.ciel`.
3. Added `GLS_NETLIST` pointing to `1_2_yosys.v`.
4. Updated `GCC_PATH` to `/usr/bin`.
5. Updated all `CPUFLAGS_*` variables to use `rv32i_zicsr`.
6. Added `check-gl`.
7. Added `check-gl` as a dependency of `%.vvp`.
8. Changed both `SIM=GL` branches to compile `$(GLS_NETLIST)`.
9. Added `check-gl` to `.PHONY`.

### `uart/Makefile`

File: [uart/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-standalone/uart/Makefile)

Applied changes:

1. Updated `DESIGNS`.
2. Updated `PDK_ROOT`.
3. Added `GLS_NETLIST`.
4. Updated `GCC_PATH` to `/usr/bin`.
5. Updated `CPUFLAGS_*` to `rv32i_zicsr`.
6. Added `check-gl`.
7. Changed `%.vvp` to depend on `check-gl`.
8. Replaced the GL wrapper path with `$(GLS_NETLIST)`.
9. Kept the existing UART-specific HEX remap:

```make
sed -i 's/^@10000000/@00000000/' $@
```

### `timer/Makefile`

File: [timer/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-standalone/timer/Makefile)

Applied changes:

1. Updated `DESIGNS`.
2. Updated `PDK_ROOT`.
3. Added `GLS_NETLIST`.
4. Updated `GCC_PATH` to `/usr/bin`.
5. Updated `CPUFLAGS_*` to `rv32i_zicsr`.
6. Added `check-gl`.
7. Changed `%.vvp` to depend on `check-gl`.
8. Replaced the GL wrapper path with `$(GLS_NETLIST)`.
9. Added `check-gl` to `.PHONY`.

### `debug/Makefile`

File: [debug/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-standalone/debug/Makefile)

Applied changes:

1. Updated `DESIGNS`.
2. Updated `PDK_ROOT`.
3. Added `GLS_NETLIST`.
4. Updated `GCC_PATH` to `/usr/bin`.
5. Updated `CPUFLAGS_*` to `rv32i_zicsr`.
6. Added `check-gl`.
7. Changed `%.vvp` to depend on `check-gl`.
8. Replaced the GL wrapper path with `$(GLS_NETLIST)`.
9. Added `check-gl` to `.PHONY`.
10. Kept the existing debug-specific HEX remap:

```make
sed -i 's/^@10000000/@00000000/' $@
```

### `gpio_mgmt`, `mem`, `irq`

During this session, the exact same GLS pattern was discussed for the remaining standalone blocks, but the explicit file edits captured above were completed for `spi_master`, `uart`, `timer`, and `debug`. The same recipe can be applied to the remaining standalone Makefiles because they follow the same structure.

## Standalone GLS execution command

For each standalone block, the GLS run command used was:

```bash
make clean
make SIM=GL
```

## Standalone GLS results

The table below records the current state based on this GLS work and the available captured outputs/screenshots in this repository.

| Block | GLS Result | Notes |
|---|---|---|
| `gpio_mgmt` | PASS | Screenshot shows `Monitor: Test Mgmt GPIO (GL) Passed`. |
| `debug` | FAIL | Timeout seen in screenshot during SRAM read/write check. |
| `mem` | PASS | GLS run completed as PASS; waveform file `GL-mem.vcd` is present in the standalone `mem` test folder. |
| `uart` | PASS | Screenshot shows `Monitor: Test UART (GL) passed`. |
| `timer` | FAIL | Timeout seen in screenshot from timer GLS run. |
| `irq` | FAIL | Screenshot shows `Monitor: Timeout, Test IRQ (GL) Failed`. |
| `spi_master` | PASS | Screenshot shows `Monitor: Test SPI Master (GL) Passed`. |

## GLS screenshot evidence

### `spi_master` GLS pass

![spi_master GLS pass](../screenshots/Screenshot%202026-04-02%20at%2012.43.41%20PM.png)

### `uart` GLS pass

![uart GLS pass](../screenshots/Screenshot%202026-04-02%20at%201.45.14%20PM.png)

### `gpio_mgmt` GLS pass

![gpio_mgmt GLS pass](../screenshots/Screenshot%202026-04-02%20at%201.37.35%20PM.png)

### `mem` GLS pass

The `mem` block GLS run is recorded as PASS. The generated waveform file is available at [GL-mem.vcd](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-standalone/mem/GL-mem.vcd).

![mem GLS pass](../Week4/Screenshot%202026-04-02%20at%203.04.13%20PM.png)

### `debug` GLS fail

![debug GLS fail](../screenshots/Screenshot%202026-04-02%20at%202.39.22%20PM.png)

### `irq` GLS fail

![irq GLS fail](../screenshots/Screenshot%202026-04-02%20at%201.47.42%20PM.png)

### `timer` GLS fail

![timer GLS fail](../screenshots/Screenshot%202026-04-02%20at%202.21.27%20PM.png)

## Summary

The Week 5 GLS setup is now working for a subset of standalone blocks after:

- integrating the synthesized `__user_project_wrapper` netlist,
- fixing workspace and toolchain paths,
- updating CPU flags for the installed RISC-V toolchain,
- repairing the shared standalone GLS file list,
- and re-running tests in `SIM=GL` mode.

Current standalone GLS status from this work:

- PASS: `gpio_mgmt`, `mem`, `uart`, `spi_master`
- FAIL: `debug`, `irq`, `timer`

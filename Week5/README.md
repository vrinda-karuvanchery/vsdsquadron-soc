# Week 5

## Gate-Level Simulation and Caravel Integration Debug

This week focused on two connected goals:

1. getting the synthesized `__user_project_wrapper` netlist into the GLS flow, and
2. extending verification from standalone tests to the full Caravel-integrated `tests-caravel` environment.

The result is mixed but meaningful progress:

- the standalone GLS flow was repaired and several blocks passed,
- the shared Caravel boot path was debugged and fixed,
- several Caravel Makefiles were repaired,
- `mem` and `spi_master` now pass in Caravel `RTL`,
- Caravel `GL` now boots far enough to start flash transactions,
- but most integrated GLS tests still fail later due to a deeper post-boot GPIO/checkpoint visibility mismatch.

## Netlist Used

- Selected GLS netlist:
  - `/workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/user_project_wrapper/base/1_2_yosys.v`
- Reason:
  - `1_2_yosys.v` is the synthesized gate-level netlist and is compatible with the reduced local simulation model set.
  - later post-route netlists such as `6_final.v` would require a much larger and cleaner set of cell/fill models than were practical in this local GLS setup.

![OpenROAD result folder showing available netlists](images/netlist_selection.png)

## Main Fixes Applied

### 1. Standalone GLS Makefile and include fixes

The standalone GLS flow was repaired first.

Applied fixes:

- corrected workspace-relative paths instead of `/home/vsduser`
- updated VexRiscv compile flags to `-march=rv32i_zicsr -mabi=ilp32`
- introduced:
  - `GLS_NETLIST ?= /workspaces/OpenROAD-flow-scripts/flow/results/sky130hd/user_project_wrapper/base/1_2_yosys.v`
- added a `check-gl` target so missing netlists fail early
- updated standalone GLS rules to compile `$(GLS_NETLIST)` instead of stale GL wrapper paths
- repaired [includes.gl.standalone](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/includes/includes.gl.standalone) to use:
  - OpenROAD example HD cell models
  - RTL `mgmt_core.v`
  - explicit RTL `RAM128.v` and `RAM256.v`

### 2. Caravel firmware and Makefile fixes

The Caravel-integrated tests needed the original management-SoC firmware flow restored.

Shared fixes applied to the Caravel test Makefiles:

- restored VexRiscv linker/startup flow:
  - `sections.lds`
  - `crt0_vex.S`
  - `isr.c`
- restored the hex remap:
  - `sed -i 's/@10/@00/g' $@`
- added `GLS_NETLIST` and `check-gl` where needed
- changed stale GL compile rules from:
  - `$(CARAVEL_PATH)/gl/__user_project_wrapper.v`
  - to `$(GLS_NETLIST)`

This Makefile fix pattern was applied to the active/debugged Caravel tests such as:

- [mem/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-caravel/mem/Makefile)
- [pll/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-caravel/pll/Makefile)
- [gpio_mgmt/Makefile](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-caravel/gpio_mgmt/Makefile)

### 3. Firmware symbol fix

[isr.c](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/firmware/isr.c) was patched so the interrupt flag symbol always links cleanly:

```c
volatile uint16_t flag __attribute__((weak)) = 0;
```

This removed the VexRiscv caravel firmware link failure caused by multiple tests sharing the same startup/interrupt support files.

### 4. Shared Caravel simulation fixes

These were the biggest shared fixes of the week.

#### [simple_por.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/simple_por.v)

Problem:
- in simulation, POR never cleanly released in the Caravel-integrated flow

Fix:
- in `SIM`, POR is released deterministically after startup instead of depending on padframe power-edge behavior

Impact:
- fixed `porb_h` staying low
- allowed flash output enables to deassert

#### [chip_io.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/chip_io.v)

Problem:
- the management clock pad path was not propagating cleanly in simulation

Fix:
- in `SIM`, `clock_core` is assigned directly from the top-level `clock`

Impact:
- fixed the dead management clock input path

#### [caravel_clocking.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/caravel_clocking.v)

Problem:
- the internal clock/reset handoff was deadlocked in simulation

Fix:
- in `SIM`, `core_clk` and `user_clk` are driven directly from `ext_clk`

Impact:
- `reset_delay` now drains
- `caravel_rstn` can go high
- flash boot begins

### 5. Caravel GLS include-file fixes

[includes.gl.caravel](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/includes/includes.gl.caravel) was substantially repaired:

- kept/added required Caravel RTL support files:
  - `debug_regs.v`
  - `buff_flash_clkrst.v`
  - `gpio_signal_buffering.v`
  - `gpio_signal_buffering_alt.v`
- kept the compatibility wrapper:
  - [user_project_wrapper_gl_compat.v](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/includes/user_project_wrapper_gl_compat.v)
- switched to the same behavioral RAM models as the passing RTL setup:
  - [RAM256.v](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/vip/RAM256.v)
  - [RAM128.v](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/vip/RAM128.v)
- retained the patched IO/lib setup needed to avoid model conflicts

### 6. Testbench-side monitoring fixes

To distinguish real boot failures from pad visibility failures, the active Caravel testbenches were instrumented with internal probes.

For `mem` and `spi_master`, the GL testbenches now monitor the internal housekeeping management GPIO bus in simulation:

- [mem_tb.v](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-caravel/mem/mem_tb.v)
- [spi_master_tb.v](/workspaces/vsdsquadron-soc/caravel_mgmt_soc_litex/verilog/dv/tests-caravel/spi_master/spi_master_tb.v)

This helped prove that:

- reset deasserts,
- flash chip select is asserted,
- flash clock toggles,
- but the final checkpoint path still does not consistently show up at the external pad-facing monitor points in GL.

### 7. Housekeeping simulation workaround

[housekeeping.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/housekeeping.v) was patched in `SIM` so the firmware does not block indefinitely on the GPIO configuration transfer busy bit:

- readback of the transfer/busy register now reports idle in `SIM`
- writes do not keep `serial_xfer` stuck active in `SIM`

This was necessary because several Caravel test firmwares wait on:

```c
while (reg_mprj_xfer == 1);
```

and that handshake was a likely point of divergence in GL.

## Result Table

The table below summarizes the current state of Week 5 work.

| Area | Test | RTL | GL | Current status |
|---|---|---:|---:|---|
| Standalone | `gpio_mgmt` | not the Week 5 focus | PASS | GLS pass captured |
| Standalone | `mem` | not the Week 5 focus | PASS | GLS pass captured |
| Standalone | `uart` | not the Week 5 focus | PASS | GLS pass captured |
| Standalone | `spi_master` | not the Week 5 focus | PASS | GLS pass captured |
| Standalone | `debug` | not the Week 5 focus | FAIL | timeout |
| Standalone | `irq` | not the Week 5 focus | FAIL | timeout |
| Standalone | `timer` | not the Week 5 focus | FAIL | timeout |
| Caravel | `mem` | PASS | FAIL | GL now boots and starts flash, then times out before checkpoint activity |
| Caravel | `spi_master` | PASS | FAIL | GL now boots and starts flash, then times out before checkpoint activity |
| Caravel | `pll` | FAIL | not completed | Makefile fixed, RTL now reaches first checkpoint but monitor/counting logic still needs work |
| Caravel | `gpio_mgmt` | not yet rerun in this cycle | compile path fixed | stale GL wrapper path repaired |

## Standalone GLS Evidence

### `spi_master` GLS pass

![spi_master GLS pass](images/spi_master_gl_pass.png)

### `uart` GLS pass

![uart GLS pass](images/uart_gl_pass.png)

### `gpio_mgmt` GLS pass

![gpio_mgmt GLS pass](images/gpio_mgmt_gl_pass.png)

### `mem` GLS pass

![mem GLS pass](images/mem_gl_pass.png)

### `debug` GLS fail

![debug GLS fail](images/debug_gl_fail.png)

### `irq` GLS fail

![irq GLS fail](images/irq_gl_fail.png)

### `timer` GLS fail

![timer GLS fail](images/timer_gl_fail.png)

## Debugging Trail

This is the condensed sequence of debugging steps that got the Caravel flow from “does not boot” to “boots, starts flash, but still fails later in GL”.

### Step 1. Fix stale GL build paths

Initial Caravel `GL` runs failed at compile time because several test Makefiles still referenced:

```make
$(CARAVEL_PATH)/gl/__user_project_wrapper.v
```

That file does not exist in this workspace. Those Makefiles were updated to use `$(GLS_NETLIST)` instead.

### Step 2. Restore the correct VexRiscv firmware flow

The Caravel tests were switched back to the correct firmware pieces:

- `sections.lds`
- `crt0_vex.S`
- `isr.c`

This also required:

- `rv32i_zicsr`
- the `flag` weak-symbol fix in `isr.c`
- restoring the correct HEX remap

Without this, some Caravel tests either did not link correctly or booted with the wrong memory image layout.

### Step 3. Prove the original Caravel GL boot path was dead

Internal probes showed:

- reset never really released cleanly,
- flash chip select stayed tri-stated,
- flash clock never started,
- and the core clock path was not functioning correctly in simulation.

### Step 4. Fix POR in simulation

After patching [simple_por.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/simple_por.v):

- `porb_h` rose,
- flash output enables deasserted,
- flash pads stopped staying at `z`

This was the first major shared breakthrough.

### Step 5. Fix the management clock path in simulation

After patching:

- [chip_io.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/chip_io.v)
- [caravel_clocking.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/caravel_clocking.v)

the probes showed:

- `caravel_rstn` rises
- `flash_csb_core` asserts low
- `flash_clk_core` toggles continuously

At that point, Caravel GL was no longer dead at boot.

### Step 6. Rule out the synthesized wrapper as the main blocker

A temporary A/B experiment replaced the synthesized wrapper with the RTL wrapper while keeping the rest of the GL stack.

Result:

- `mem` GL still timed out

Conclusion:

- the remaining Caravel GL failure is not mainly caused by the synthesized wrapper choice

### Step 7. Check whether GPIO checkpoints are present internally

For `mem` and `spi_master`, internal housekeeping and flash probes showed:

- boot starts,
- flash transactions happen,
- but the user-visible checkpoint signals never appear reliably at the monitored external pad path in GL

This pushed the debugging focus away from firmware image loading and toward the post-boot GPIO/checkpoint visibility path.

### Step 8. Reduce the testbench dependence on the final pad path

The GL testbenches for `mem` and `spi_master` were changed to watch:

- `uut.chip_core.mgmt_io_out_hk[...]`

instead of only:

- `mprj_io[...]`

This made the debug more truthful: the management-side GPIO bus can move even when the final pad-facing representation does not.

### Step 9. Identify the next likely common blocker

Both `mem.c` and `spi_master.c` perform GPIO configuration and then wait for:

```c
while (reg_mprj_xfer == 1);
```

That pointed to the housekeeping GPIO serial-loader handshake as another common simulation mismatch. A `SIM` workaround was added in [housekeeping.v](/workspaces/vsdsquadron-soc/caravel/verilog/rtl/housekeeping.v) to prevent firmware from stalling forever on that transfer-busy bit.

### Step 10. `pll` moved into a different failure mode

Unlike `mem` and `spi_master`, `pll` still failed in `RTL`, so it was debugged separately.

Current `pll` state:

- Makefile GL compile path was fixed
- duplicated padframe supplies were added in the testbench
- `RTL` now reaches the first checkpoint
- but the test still fails on the clock-monitor counting path

So `pll` is no longer a dead boot failure, but it is not finished yet.

## Why Most Caravel GLS Tests Are Still Failing

The remaining GLS failures are mostly not simple “firmware did not boot” problems anymore.

The evidence from `mem` and `spi_master` shows:

- reset releases correctly,
- flash chip select asserts,
- flash clock toggles,
- the management SoC is running far enough to begin SPI flash activity

but the tests still fail before their expected user-visible checkpoint outputs appear.

The most likely reasons are:

1. **Padframe and GPIO visibility mismatch in GL**
   - internal housekeeping GPIO signals move,
   - but the final observed `mprj_io[...]` path does not always reflect them in simulation

2. **GPIO configuration serial-loader behavior differs in GL**
   - several firmwares wait on `reg_mprj_xfer`
   - the serial configuration chain is a long pad-centric path and is more fragile in GL than in RTL

3. **These integrated tests depend on more than flash boot**
   - passing flash boot only proves the CPU starts
   - it does not prove the later housekeeping-to-pad checkpoint path is correct

4. **`pll` adds an extra clock-monitoring dependency**
   - it depends not only on checkpoint GPIO writes
   - but also on redirected clock observation and accurate counting

So the current dominant GLS issue is best described as:

> the shared Caravel boot path is fixed, but the post-boot management-GPIO/checkpoint path still diverges in gate-level simulation.

## Current Takeaway

Week 5 achieved two major outcomes:

1. the standalone GLS flow was brought up and validated on multiple blocks, and
2. the Caravel-integrated environment moved from “GL does not boot” to “GL boots and reaches post-boot behavior”.

That is significant progress, even though the full Caravel GLS matrix is not green yet.

## Next Steps

- finish the `pll` RTL monitor fix
- rerun `pll` GL after the Makefile repair
- rerun `gpio_mgmt` GL after the Makefile repair
- apply the corrected Caravel Makefile pattern to the remaining `tests-caravel` directories
- continue shared debugging at the housekeeping-to-GPIO/checkpoint path instead of treating each test as an isolated failure

# Week 3 Verification and SPI Debug Notes

This directory captures the Week 3 verification work for the management SoC, with emphasis on the debugging that was required before the standalone SPI test could be run from the `spi_master` folder.

## Verification Flow Overview

![Week 3 verification flow](../screenshots/Slide1.png)

The flow begins by compiling the firmware, linker inputs, and RTL testbench so the simulator can build a complete standalone verification setup.
The generated hex image is then loaded into simulated memory, and the RISC-V management core executes the test program against the target peripheral logic.
During simulation, the testbench monitors register activity, protocol behavior, and waveform checkpoints to compare the observed responses with the expected results.
If the logs, checkpoints, and waveform outputs all match, the design is treated as functionally verified for the covered cases and ready for further integration or debug closure.

## Directory Contents

- `README.md`: Week 3 verification summary and SPI debug flow
- `caravel_results.md`: Notes from the Caravel-side verification work
- `diagrams/`: Supporting diagrams used during verification
- `screenshots/`: Terminal captures from the SPI debug session

## SPI Debugging Before `make run`

The SPI bring-up work started in:

`caravel_mgmt_soc_litex/verilog/dv/tests-standalone/spi_master`

The screenshots below document the issues that had to be cleared before the SPI testbench could be built and run cleanly.

### 1. Confirm the SPI test directory contents

The first step was to check that the standalone SPI test folder contained the expected firmware source, testbench, hex, GTKWave setup, and Makefile inputs.

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.21.41%20PM.png" alt="SPI master directory contents" width="900">

This verified that the working folder already had:

- `spi_master.c`
- `spi_master_tb.v`
- `spi_master.hex`
- `spi_master.gtkw`
- `Makefile`

### 2. Resolve the missing `regions.ld` linker include

The first `make` attempt failed during the `prepare-generated` stage because the linker include file `regions.ld` was missing from the path expected by the SPI test flow:

`/home/vsduser/caravel_mgmt_soc_litex/verilog/dv/generated/regions.ld`

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.24.52%20PM.png" alt="Missing generated regions.ld error" width="900">

This was the first clear sign that the test Makefile still needed path cleanup for the current workspace layout under `/workspaces/vsdsquadron-soc`. The generated linker data had to be made visible through `tests-standalone/generated/regions.ld` before firmware linking could continue.

### 3. Fix the `defs.h` debug-register definition issue

After the generated linker path problem was addressed, the build moved forward and then stopped in `caravel_mgmt_soc_litex/verilog/dv/firmware/defs.h` around line 146, where an old `reg_debug_1` definition conflicted with the active definition later in the file.

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.43.26%20PM.png" alt="defs.h previous definition note for reg_debug_1" width="900">

This stage was important because it showed that the firmware headers were now being compiled correctly, and the remaining problem had shifted from directory setup to source-level cleanup in the debug register definitions.

### 4. Correct the VexRiscv startup build settings

Once the header issue was cleared, the build reached the startup assembly and failed on the instruction:

`csrw mtvec,t0`

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.48.31%20PM.png" alt="Assembler error for csrw mtvec t0" width="900">

This showed that the firmware build flags had to match the VexRiscv CPU configuration. The startup file `start_caravel_vexriscv.s` requires CSR support, so the compiler options had to be aligned with the correct RISC-V ISA settings before `spi_master.elf` could be generated.

### 5. Restore the simulator tool invocation

After the firmware build stage succeeded, the flow reached RTL compilation and then failed because `iverilog` was not being found.

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.51.51%20PM.png" alt="iverilog not found error" width="900">

At this point the debug focus moved from firmware generation to simulation environment setup. The Makefile was already trying to build `spi_master.vvp`, but the simulator executable had to be available in the environment for the run target to proceed.

### 6. Fix missing SRAM model path references

With the simulator path issue addressed, the next failure came from a missing SRAM model reference:

`sky130_sram_2kbyte_1rw1r_32x512_8.v`

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.54.09%20PM.png" alt="Missing SRAM model error" width="900">

This indicated that the include list was still pointing at a model path that did not exist in the current setup. The SPI test could not elaborate until the SRAM model path was made consistent with the workspace contents.

### 7. Resolve the missing `debug_regs` module during RTL elaboration

The last pre-run blocker shown in the screenshots was an RTL elaboration error from `__user_project_wrapper.v`, where `debug_regs` was reported as an unknown module type.

<img src="./screenshots/Screenshot%202026-03-20%20at%2012.57.54%20PM.png" alt="Unknown module type debug_regs error" width="900">

This confirmed that the remaining issue was no longer in the SPI test itself, but in the top-level standalone RTL include chain. The Caravel RTL sources and include files had to be aligned so `debug_regs.v` was visible during elaboration.

## Summary

Before the SPI test could be run cleanly, the debug work progressed through four main classes of issues:

1. workspace path mismatches
2. firmware header cleanup
3. CPU/toolchain alignment
4. RTL dependency and simulator setup

These screenshots therefore document the complete pre-`make run` debug trail for the standalone SPI test, from folder validation up to the final unresolved RTL dependency checks.

## Current Standalone Status

Based on the current Week 3 standalone verification runs:

- `uart`: passed
- `mem`: passed
- `gpio_mgmt`: passed
- `spi_master`: passed
- `debug`: failed
- `timer`: failed
- `irq`: failed

At this stage, the main completed standalone blocks are `uart`, `mem`, `gpio_mgmt`, and `spi_master`, while `debug`, `timer`, and `irq` still require additional debug on the firmware and/or testbench side.

## What A Successful `make` Run Means

For the standalone SPI test, a successful `make` run means the complete verification flow finished correctly:

1. the SPI firmware was compiled
2. the firmware was converted into a hex memory image
3. the RTL testbench was compiled
4. the simulation ran
5. the SPI data checks passed

In practice, the most important success message is:

`Monitor: Test SPI Master (RTL) Passed`

That means the testbench observed the expected SPI read values and ended normally.

## Files To Validate

After a successful run, these files are the main validation artifacts:

- `spi_master.hex`: firmware image loaded into simulated memory
- `spi_master.lst`: disassembly listing of the compiled firmware
- `RTL-spi_master.vcd`: waveform dump from the RTL simulation
- `spi_master_tb.v`: testbench containing the pass/fail checks

If `spi_master.hex`, `spi_master.lst`, and `RTL-spi_master.vcd` exist and the terminal prints `Passed`, the standalone SPI verification flow completed successfully.

## Firmware, CPU, Registers, And SPI

The file `spi_master.c` is the firmware for this test. It is a small RISC-V program that runs on the management CPU inside the simulated SoC. The firmware does not toggle SPI pins directly. Instead, it writes to memory-mapped control and status registers such as the SPI data, control, chip-select, and status registers.

The connection is:

`spi_master.c -> RISC-V CPU -> memory-mapped registers -> SPI master hardware -> SPI flash model`

This means the CPU executes the firmware, the firmware writes to register addresses, those register writes control the SPI master hardware, and the hardware communicates with the SPI flash model used by the testbench.

## What Simulated Memory Means

Simulated memory is the virtual memory model inside the Verilog simulation. It holds the firmware image so the RISC-V CPU has instructions to fetch and execute during simulation. In this flow, `spi_master.c` is compiled first, then converted into `spi_master.hex`, and that hex file is loaded into simulated memory before the CPU starts running.

So there are two different things involved in this test:

- simulated memory used by the CPU to run the firmware
- SPI flash model used as the external device accessed by the SPI master

## `make` Flow Diagram

When `make` is invoked inside the standalone `spi_master` folder, the build and simulation flow is:

```text
make
  -> prepare-generated
     -> create ../generated
     -> link ../generated/regions.ld to dv/generated/regions.ld
  -> check-fw
     -> verify linker script and startup files exist
  -> compile firmware
     -> spi_master.c + start_caravel_vexriscv.s
     -> spi_master.elf
  -> convert executable to memory image
     -> spi_master.hex
  -> compile RTL simulation
     -> spi_master_tb.v + included RTL files
     -> spi_master.vvp
  -> run simulation
     -> vvp spi_master.vvp
     -> spi_master.vcd
     -> rename to RTL-spi_master.vcd
  -> generate disassembly
     -> spi_master.lst
```

In short, `make` first prepares the firmware inputs, then builds the firmware, then builds and runs the RTL simulation, and finally generates the main debug artifacts used for validation.

## Verilog Sources And Simulation Tools

The standalone SPI simulation is built with `iverilog` and executed with `vvp`.

The main files involved are:

- `spi_master_tb.v`: the Verilog testbench
- `__user_project_wrapper.v`: top-level wrapper added by the Makefile
- `includes.rtl.standalone`: include list that pulls in the management SoC RTL, CPU RTL, debug logic, RAM models, and SPI flash model

So the simulation environment is created by compiling the SPI testbench together with the management SoC RTL and the required memory and peripheral models.

## What User Project Means In Caravel

In Caravel, the **user project** is the design that you place inside the reusable Caravel platform. Caravel provides the surrounding infrastructure such as the management CPU, buses, GPIO handling, power, clocking, and reset, while the user-project area is where your own RTL lives.

In this repository, the user project is the custom logic being developed and verified inside that platform, such as the SPI-related logic and other SoC blocks under test. So when a `tests-caravel` flow is run, the verification target is the complete integration of:

`Caravel platform + user project RTL`

That distinction matters because Caravel itself is the wrapper and infrastructure, while the user project is the design you are actually trying to prove works correctly inside it.

## How Pass/Fail Is Determined

The pass/fail decision is made inside `spi_master_tb.v`, not by `make` itself. The firmware running on the simulated RISC-V CPU writes checkpoint values into `reg_la0_data`, and the testbench monitors those values.

At each checkpoint, the testbench compares the observed SPI byte against the expected value. If any byte is wrong, the testbench prints `Failed` and stops. If the firmware reaches the final checkpoint and all compared values match, the testbench prints:

`Monitor: Test SPI Master (RTL) Passed`

The testbench also contains a timeout path, so the test can fail if the expected sequence never completes.

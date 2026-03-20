# Week 3 Verification and SPI Debug Notes

This directory captures the Week 3 verification work for the management SoC, with emphasis on the debugging that was required before the standalone SPI test could be run from the `spi_master` folder.

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

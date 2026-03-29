## OpenROAD Flow Notes

- Platform: `sky130hd`
- Design: `user_project_wrapper`
- Working Verilog define added for synthesis: `-DMPRJ_IO_PADS=38`
- Floorplan used explicit geometry:
  - `DIE_AREA = 0 0 2200 2200`
  - `CORE_AREA = 10 10 2190 2190`
- Placement density used: `0.55`

## Key issues resolved

- Yosys failed until `MPRJ_IO_PADS` was passed through `VERILOG_DEFINES`.
- IO placement failed with the default floorplan because the die perimeter was too small for the number of IO pins.
- Enlarging the die/core area allowed floorplan and placement to proceed.

## Flow status observed

- Synthesis completed successfully.
- Floorplan completed successfully.
- Detailed routing log converged to `0` violations.
- Antenna report showed `0` net violations and `0` pin violations.

## Useful ORFS commands

```bash
cd /workspaces/OpenROAD-flow-scripts/flow
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk synth
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk floorplan
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk place
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk cts
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk route
make DESIGN_CONFIG=./designs/sky130hd/user_project_wrapper/config.mk finish
```

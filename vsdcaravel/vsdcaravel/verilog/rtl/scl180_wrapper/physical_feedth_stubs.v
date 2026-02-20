// physical_feedth_stubs.v
// SCL180 feedthrough / filler cells
// No logical function – physical-only cells for PnR

`timescale 1ns/1ps

module feedth3 (
`ifdef USE_POWER_PINS
  inout VDD,
  inout VSS
`endif
);
endmodule


module feedth (
`ifdef USE_POWER_PINS
  inout VDD,
  inout VSS
`endif
);
endmodule

`timescale 1ns/1ps

module feedth9 (
`ifdef USE_POWER_PINS
  inout VDD,
  inout VSS
`endif
);
  // No functionality: physical-only filler/feedthrough for PnR.
endmodule


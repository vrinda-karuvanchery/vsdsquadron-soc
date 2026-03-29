`default_nettype none
module sky130_fd_io__top_xres4v2 (
    inout AMUXBUS_A, inout AMUXBUS_B,
    input DISABLE_PULLUP_H, input ENABLE_H, input ENABLE_VDDIO, input EN_VDDIO_SIG_H,
    input FILT_IN_H, input INP_SEL_H, inout PAD, input PAD_A_ESD_H, input PULLUP_H,
    input TIE_HI_ESD, input TIE_LO_ESD, input TIE_WEAK_HI_H,
    inout VCCD, inout VCCHIB, inout VDDA, inout VDDIO, inout VDDIO_Q,
    inout VSSA, inout VSSD, inout VSSIO, inout VSSIO_Q, inout VSWITCH,
    output XRES_H_N
);
assign XRES_H_N = PAD;
endmodule
`default_nettype wire

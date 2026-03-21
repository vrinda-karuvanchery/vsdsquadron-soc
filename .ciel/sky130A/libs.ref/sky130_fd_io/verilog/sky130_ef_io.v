`default_nettype none

module sky130_ef_io__analog_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout P_CORE,
    inout P_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
    tran pad_link(P_CORE, P_PAD);
endmodule

module sky130_ef_io__corner_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__gpiov2_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    input ANALOG_EN,
    input ANALOG_POL,
    input ANALOG_SEL,
    input [2:0] DM,
    input ENABLE_H,
    input ENABLE_INP_H,
    input ENABLE_VDDA_H,
    input ENABLE_VDDIO,
    input ENABLE_VSWITCH_H,
    input HLD_H_N,
    input HLD_OVR,
    input IB_MODE_SEL,
    output IN,
    output IN_H,
    input INP_DIS,
    input OE_N,
    input OUT,
    inout PAD,
    input PAD_A_ESD_0_H,
    input PAD_A_ESD_1_H,
    input PAD_A_NOESD_H,
    input SLOW,
    input TIE_HI_ESD,
    input TIE_LO_ESD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH,
    input VTRIP_SEL
);
    assign PAD = OE_N ? 1'bz : OUT;
    assign IN = PAD;
    assign IN_H = PAD;
endmodule

module sky130_ef_io__gpiov2_pad_wrapped (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    input ANALOG_EN,
    input ANALOG_POL,
    input ANALOG_SEL,
    input [2:0] DM,
    input ENABLE_H,
    input ENABLE_INP_H,
    input ENABLE_VDDA_H,
    input ENABLE_VDDIO,
    input ENABLE_VSWITCH_H,
    input HLD_H_N,
    input HLD_OVR,
    input IB_MODE_SEL,
    output IN,
    output IN_H,
    input INP_DIS,
    input OE_N,
    input OUT,
    inout PAD,
    input PAD_A_ESD_0_H,
    input PAD_A_ESD_1_H,
    input PAD_A_NOESD_H,
    input SLOW,
    input TIE_HI_ESD,
    input TIE_LO_ESD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH,
    input VTRIP_SEL
);
    assign PAD = OE_N ? 1'bz : OUT;
    assign IN = PAD;
    assign IN_H = PAD;
endmodule

module sky130_ef_io__top_power_hvc (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout P_CORE,
    inout P_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
    tran power_link(P_CORE, P_PAD);
endmodule

module sky130_ef_io__vccd_lvc_clamped3_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VCCD1,
    inout VCCD_PAD,
    inout VSSD1,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vccd_lvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VCCD_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vdda_hvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VDDA_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vddio_hvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VDDIO_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vssa_hvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VSSA_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vssd_lvc_clamped3_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VCCD1,
    inout VSSD1,
    inout VSSD_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vssd_lvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VSSD_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_io__vssio_hvc_clamped_pad (
    inout AMUXBUS_A,
    inout AMUXBUS_B,
    inout VSSIO_PAD,
    inout VCCD,
    inout VCCHIB,
    inout VDDA,
    inout VDDIO,
    inout VDDIO_Q,
    inout VSSA,
    inout VSSD,
    inout VSSIO,
    inout VSSIO_Q,
    inout VSWITCH
);
endmodule

module sky130_ef_sc_hd__decap_12 (
    inout VGND,
    inout VNB,
    inout VPB,
    inout VPWR
);
endmodule

`default_nettype wire

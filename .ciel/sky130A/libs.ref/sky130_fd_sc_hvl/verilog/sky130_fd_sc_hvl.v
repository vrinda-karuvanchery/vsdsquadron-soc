`default_nettype none
module sky130_fd_sc_hvl__conb_1(inout VGND,inout VNB,inout VPB,inout VPWR,output HI,output LO); assign HI=1'b1; assign LO=1'b0; endmodule
module sky130_fd_sc_hvl__lsbufhv2lv_1(input A,input LVPWR,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hvl__schmittbuf_1(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
`default_nettype wire

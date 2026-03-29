`default_nettype none
module sky130_fd_sc_hd__and2_1(input A,input B,input CGAND,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A&B; endmodule
module sky130_fd_sc_hd__and3_2(input A,input B,input C,input AND3,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A&B&C; endmodule
module sky130_fd_sc_hd__and3b_2(input A_N,input B,input C,input AND1,input AND2,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=(~A_N)&B&C; endmodule
module sky130_fd_sc_hd__and4_2(input A,input B,input C,input D,input AND7,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A&B&C&D; endmodule
module sky130_fd_sc_hd__and4b_2(input A_N,input B,input C,input D,input AND3,input AND5,input AND6,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=(~A_N)&B&C&D; endmodule
module sky130_fd_sc_hd__and4bb_2(input A_N,input B_N,input C,input D,input AND1,input AND2,input AND4,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=(~A_N)&(~B_N)&C&D; endmodule
module sky130_fd_sc_hd__buf_8(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__buf_16(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkbuf_1(input A,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkbuf_2(input A,input ENBUF,input SEL0BUF,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkbuf_4(input A,input CLKBUF,input Root_CLKBUF,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkbuf_8(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkbuf_16(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=A; endmodule
module sky130_fd_sc_hd__clkinv_1(input A,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__clkinv_2(input A,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__clkinv_8(input A,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__conb_1(inout VGND,inout VNB,inout VPB,inout VPWR,output HI,output LO); assign HI=1'b1; assign LO=1'b0; endmodule
module sky130_fd_sc_hd__decap_3(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__decap_4(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__decap_6(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__decap_8(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__decap_12(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__dfbbp_1(input CLK,input D,input RESET_B,input SET_B,inout VGND,inout VNB,inout VPB,inout VPWR,output reg Q,output Q_N); always @(posedge CLK or negedge RESET_B or negedge SET_B) if(!RESET_B) Q<=1'b0; else if(!SET_B) Q<=1'b1; else Q<=D; assign Q_N=~Q; endmodule
module sky130_fd_sc_hd__dfxtp_1(input CLK,input D,inout VGND,inout VNB,inout VPB,inout VPWR,output reg Q); always @(posedge CLK) Q<=D; endmodule
module sky130_fd_sc_hd__diode_2(inout DIODE,input DIODE_CLK,inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__dlclkp_1(input CLK,input GATE,input CG,inout VGND,inout VNB,inout VPB,inout VPWR,output GCLK); assign GCLK=CLK&GATE; endmodule
module sky130_fd_sc_hd__dlxtp_1(input D,input GATE,input STORAGE,inout VGND,inout VNB,inout VPB,inout VPWR,output reg Q); always @* if(GATE) Q=D; endmodule
module sky130_fd_sc_hd__ebufn_2(input A,input TE_B,input OBUF0,inout VGND,inout VNB,inout VPB,inout VPWR,output Z); assign Z=TE_B?A:1'bz; endmodule
module sky130_fd_sc_hd__einvn_4(input A,input TE_B,output Z); assign Z=TE_B?~A:1'bz; endmodule
module sky130_fd_sc_hd__einvn_8(input A,input TE_B,output Z); assign Z=TE_B?~A:1'bz; endmodule
module sky130_fd_sc_hd__einvp_1(input A,input TE,output Z); assign Z=TE?~A:1'bz; endmodule
module sky130_fd_sc_hd__einvp_2(input A,input TE,output Z); assign Z=TE?~A:1'bz; endmodule
module sky130_fd_sc_hd__fill_2(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__inv_1(input A,input CLKINV,input SEL0INV,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__inv_2(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__inv_8(input A,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~A; endmodule
module sky130_fd_sc_hd__macro_sparecell(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
module sky130_fd_sc_hd__mux2_2(input A0,input A1,input S,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=S?A1:A0; endmodule
module sky130_fd_sc_hd__mux4_1(input A0,input A1,input A2,input A3,input S0,input S1,inout VGND,inout VNB,inout VPB,inout VPWR,output X); assign X=S1?(S0?A3:A2):(S0?A1:A0); endmodule
module sky130_fd_sc_hd__nand2_2(input A,input B,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~(A&B); endmodule
module sky130_fd_sc_hd__nand2_4(input A,input B,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~(A&B); endmodule
module sky130_fd_sc_hd__nor2_2(input A,input B,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~(A|B); endmodule
module sky130_fd_sc_hd__nor3b_2(input A,input B,input C_N,input AND0,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~(A|B|(~C_N)); endmodule
module sky130_fd_sc_hd__nor4b_2(input A,input B,input C,input D_N,input AND0,inout VGND,inout VNB,inout VPB,inout VPWR,output Y); assign Y=~(A|B|C|(~D_N)); endmodule
module sky130_fd_sc_hd__or2_2(input A,input B,output X); assign X=A|B; endmodule
module sky130_fd_sc_hd__tapvpwrvgnd_1(inout VGND,inout VNB,inout VPB,inout VPWR); endmodule
`default_nettype wire

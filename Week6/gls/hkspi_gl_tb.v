`timescale 1ns / 1ps
`default_nettype none

module hkspi_gl_tb;

    reg reset;
    reg SCK;
    reg SDI;
    reg CSB;
    reg [7:0] idata;

    wire SDO;
    wire sdoenb;
    wire [7:0] odata;
    wire [7:0] oaddr;
    wire rdstb;
    wire wrstb;
    wire pass_thru_mgmt;
    wire pass_thru_mgmt_delay;
    wire pass_thru_user;
    wire pass_thru_user_delay;
    wire pass_thru_mgmt_reset;
    wire pass_thru_user_reset;

    integer i;
    reg [7:0] readback;
    reg saw_rdstb;
    reg saw_wrstb;
    reg saw_pass_thru_mgmt;
    reg saw_pass_thru_user;
    reg [7:0] last_read_addr;
    reg [7:0] last_write_addr;

    housekeeping_spi dut (
        .reset(reset),
        .SCK(SCK),
        .SDI(SDI),
        .CSB(CSB),
        .SDO(SDO),
        .sdoenb(sdoenb),
        .idata(idata),
        .odata(odata),
        .oaddr(oaddr),
        .rdstb(rdstb),
        .wrstb(wrstb),
        .pass_thru_mgmt(pass_thru_mgmt),
        .pass_thru_mgmt_delay(pass_thru_mgmt_delay),
        .pass_thru_user(pass_thru_user),
        .pass_thru_user_delay(pass_thru_user_delay),
        .pass_thru_mgmt_reset(pass_thru_mgmt_reset),
        .pass_thru_user_reset(pass_thru_user_reset)
    );

    task start_csb;
        begin
            SCK <= 1'b0;
            SDI <= 1'b0;
            CSB <= 1'b0;
            #200;
        end
    endtask

    task end_csb;
        begin
            SCK <= 1'b0;
            SDI <= 1'b0;
            CSB <= 1'b1;
            #50;
        end
    endtask

    task write_byte;
        input [7:0] txdata;
        begin
            SCK <= 1'b0;
            for (i = 7; i >= 0; i = i - 1) begin
                #150;
                SDI <= txdata[i];
                #150;
                SCK <= 1'b1;
                #200;
                SCK <= 1'b0;
            end
        end
    endtask

    task read_byte;
        output [7:0] rxdata;
        begin
            SCK <= 1'b0;
            SDI <= 1'b0;
            for (i = 7; i >= 0; i = i - 1) begin
                #200;
                rxdata[i] = SDO;
                #150;
                SCK <= 1'b1;
                #200;
                SCK <= 1'b0;
            end
        end
    endtask

    always @(posedge rdstb) begin
        saw_rdstb <= 1'b1;
        last_read_addr <= oaddr;
    end

    always @(posedge wrstb) begin
        saw_wrstb <= 1'b1;
        last_write_addr <= oaddr;
    end

    always @(posedge pass_thru_mgmt) begin
        saw_pass_thru_mgmt <= 1'b1;
    end

    always @(posedge pass_thru_user) begin
        saw_pass_thru_user <= 1'b1;
    end

    initial begin
        $dumpfile("hkspi_gl.vcd");
        $dumpvars(0, hkspi_gl_tb);

        reset = 1'b0;
        SCK = 1'b0;
        SDI = 1'b0;
        CSB = 1'b0;
        idata = 8'hA5;
        readback = 8'h00;
        saw_rdstb = 1'b0;
        saw_wrstb = 1'b0;
        saw_pass_thru_mgmt = 1'b0;
        saw_pass_thru_user = 1'b0;
        last_read_addr = 8'h00;
        last_write_addr = 8'h00;

        #200;
        reset = 1'b1;
        #200;
        reset = 1'b0;
        #200;
        CSB = 1'b1;
        #200;

        // Read command: 0x40, address 0x12, then return idata = 0xA5.
        saw_rdstb = 1'b0;
        start_csb();
        write_byte(8'h40);
        write_byte(8'h12);
        #50;
        read_byte(readback);
        end_csb();
        #20;
        if (readback !== 8'hA5) begin
            $display("FAIL: expected readback 0xA5, got 0x%02x", readback);
            $finish;
        end
        if (sdoenb !== 1'b1) begin
            $display("FAIL: sdoenb should release after CSB deassertion");
            $finish;
        end

        // Write command: 0x80, address 0x34, data 0xC3.
        saw_wrstb = 1'b0;
        start_csb();
        write_byte(8'h80);
        write_byte(8'h34);
        write_byte(8'hC3);
        #50;
        if (saw_wrstb !== 1'b1) begin
            $display("FAIL: write strobe was not observed during write transaction");
            $finish;
        end
        if (last_write_addr !== 8'h34) begin
            $display("FAIL: expected write strobe address 0x34, got 0x%02x", last_write_addr);
            $finish;
        end
        if (oaddr !== 8'h35) begin
            $display("FAIL: expected post-write auto-incremented address 0x35, got 0x%02x", oaddr);
            $finish;
        end
        end_csb();
        #20;

        // Pass-through management command 0xC4.
        saw_pass_thru_mgmt = 1'b0;
        start_csb();
        write_byte(8'hC4);
        write_byte(8'h00);
        #20;
        if (saw_pass_thru_mgmt !== 1'b1) begin
            $display("FAIL: management pass-through was not asserted");
            $finish;
        end
        end_csb();
        #20;

        // Pass-through user command 0xC2.
        saw_pass_thru_user = 1'b0;
        start_csb();
        write_byte(8'hC2);
        write_byte(8'h00);
        #20;
        if (saw_pass_thru_user !== 1'b1) begin
            $display("FAIL: user pass-through was not asserted");
            $finish;
        end
        end_csb();
        #20;

        $display("PASS: housekeeping_spi direct testbench completed");
        $finish;
    end

endmodule

`default_nettype wire

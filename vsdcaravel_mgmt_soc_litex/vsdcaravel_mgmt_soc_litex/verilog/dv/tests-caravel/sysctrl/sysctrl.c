#include <defs.h>

// --------------------------------------------------------

// NEW: RV32I-safe delay (no rdcycle). Volatile + nop prevents optimization.
static inline void delay_loops(volatile unsigned int n)   // <<< NEW
{
    while (n--) {                                         // <<< NEW
        __asm__ volatile ("nop");                         // <<< NEW
    }
}

void main()
{
    int i;

    reg_mprj_datal = 0;

    // Configure upper 16 bits of user GPIO for generating testbench checkpoints.
    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    /* Monitor pins must be set to output */
    reg_mprj_io_15 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    /*
     *-------------------------------------------------------------
     * Register 2620_0004  reg_clk_out_dest
     * bit 1 = clk  to mprj_io[14]
     * bit 2 = clk2 to mprj_io[15]
     *-------------------------------------------------------------
     */

    // -------------------------
    // Test 0: monitoring OFF
    // -------------------------
    reg_mprj_datal = 0xA0400000;
    reg_clk_out_dest = 0x0;
    delay_loops(2000);                 // <<< NEW: small wait (must NOT hang / timeout)
    reg_mprj_datal = 0xA0410000;

    // -------------------------
    // Test 1: core clock count
    // -------------------------
    reg_mprj_datal = 0xA0420000;
    reg_clk_out_dest = 0x2;
    delay_loops(12000);                // <<< NEW: start value (tune only this if needed)
    reg_clk_out_dest = 0x0;
    reg_mprj_datal = 0xA0430000;

    // -------------------------
    // Test 2: user clock count
    // -------------------------
    reg_mprj_datal = 0xA0440000;
    reg_clk_out_dest = 0x4;
    delay_loops(12000);                // <<< NEW: start value (tune only this if needed)
    reg_clk_out_dest = 0x0;
    reg_mprj_datal = 0xA0450000;

    // End test
    reg_mprj_datal = 0xA0900000;
}


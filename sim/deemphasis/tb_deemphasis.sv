/* Testbench de-emphasis filter */

module tb_deemphasis;
   timeunit 1ns;
   timeprecision 1ps;

   localparam width = 16;

   const real tclk = 1s / 32.0e3;

   bit                reset; // reset
   bit                clk;   // clock
   bit  [width - 1:0] in;    // input
   wire [width - 1:0] out;   // filtered result

   deemphasis #(width) dut(.*);

   always #(tclk/2) clk = ~clk;

   initial
     begin:main
        reset = 1'b1;
        @(negedge clk);
        reset = 1'b0;
        repeat (10) @(negedge clk);

        /* impulse response */
        in = 2**(width - 1) - 1;
        @(negedge clk);
        in = '0;
        repeat (30) @(negedge clk);

        in = -(2**(width - 1) - 1);
        @(negedge clk);
        in = '0;
        repeat (30) @(negedge clk);

        /* step response */
        in = 2**(width - 1) - 1;
        repeat (30) @(negedge clk);

        in = '0;
        repeat (30) @(negedge clk);

        in = -(2**(width - 1) - 1);
        repeat (30) @(negedge clk);

        in = '0;
        repeat (30) @(negedge clk);

        #100us $finish;
     end:main
endmodule

/* Testbench I/Q modulator */

module tb_test_tone;
   timeunit 1ns;
   timeprecision 1fs;

   const realtime tclk = 1s / 240.0e6;
   const int      M = 240000000 / 32000;

   bit         reset; // reset
   bit         clk;   // clock
   bit         en;    // clock enable ( 32 kHz)
   wire [15:0] data;  // audio data

   test_tone dut(.*);

   always #(tclk/2) clk = ~clk;

   always @(posedge clk)
     if (reset)
       en <= 1'b0;
     else
       begin
          repeat (M  - 1) @(posedge clk);
          en <= 1'b1;
          @(posedge clk);
          en <= 1'b0;
       end

   initial
     begin:main
        reset = 1'b1;
        repeat (2) @(negedge clk);
        reset = 1'b0;

        #3ms $finish;
     end:main
endmodule

/* Testbench clock and reset unit (CRU) */

module tb_cru;
   timeunit 1ns;
   timeprecision 1ps;

   localparam M1 = 250; // carrier to broad-band frequency ratio
   localparam M2 = 30;  // broad-band to audio frequency ratio

   const real tclk_s = 1s / 240.0e6;

   bit  reset_in;    // external reset
   bit  clk_s;       // 240 MHz sampling clock
   wire clk_b;       // 960 kHz base-band clock
   wire clk_a;       // 32 kHz audio clock
   wire reset_out_s; // reset sampling clock domain
   wire reset_out_b; // reset base-band clock domain
   wire reset_out_a; // audio clock domain

   clock_unit
     #(.M1(M1), .M2(M2))
   cu
     (.reset(reset_out_s),
      .*);

   reset_unit ru(.*);

   always #(tclk_s/2) clk_s = ~clk_s;

   initial
     begin:main
        reset_in = 1'b1;
        #10ns;
        reset_in = 1'b0;

        repeat (10 * M1 * M2) @(negedge clk_s);

        #100us $finish;
     end:main
endmodule

/* Testbench clock and reset unit (CRU) */

module tb_cru;
   timeunit 1ns;
   timeprecision 1ps;

   const real tclk240m = 1s / 240.0e6;

   bit  reset_in; // power-on reset
   wire rst240m;  // 240 MHz clock domain
   wire rst12m;   //  12 MHz clock domain
   wire rst960k;  // 960 kHz clock domain
   wire rst32k;   // 32 kHz clock domain

   bit  clk240m;  // 240 MHz clock
   wire clk12m;   //  12 MHz clock
   wire clk2m;    //   2 MHz clock
   wire clk960k;  // 960 kHz clock
   wire clk32k;   //  32 kHz clock

   cru dut(.*);

   always #(tclk240m/2) clk240m = ~clk240m;

   initial
     begin:main
        reset_in = 1'b1;
        #10ns;
        reset_in = 1'b0;

        #300us $finish;
     end:main
endmodule

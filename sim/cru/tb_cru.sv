/* Testbench clock and reset unit (CRU) */

module tb_cru;
   timeunit 1ns;
   timeprecision 1ps;

   const real tclk240m = 1s / 240.0e6;

   bit  reset_in;  // power-on reset
   wire reset_out; // synchronized reset

   bit  clk240m;   // 240 MHz clock

   wire en960k;    // 960 kHz clock
   wire en32k;     //  32 kHz clock

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

/* Testbench I/Q modulator */

module tb_iq_mix;
   timeunit 1ns;
   timeprecision 1fs;

   const realtime tc   = 1s / 10.0e6,          // carrier frequency
                  tclk = 1s / (2**18 * 1.0e3); // sampling clock

   const bit [31:0] K = 2.0**32 * tclk / tc;

   bit                clk;
   bit                adc;
   bit  signed [31:0] phase;
   wire signed [1:0]  I, Q;



   iq_modulator dut(.phase(phase[31:30]), .*);

   always #(tc/2)   adc = ~adc;
   always #(tclk/2) clk = ~clk;

   always @(posedge clk)
     phase <= phase + K;

   initial
     begin:main
        repeat (1000) @(posedge clk);
        $finish;
     end:main
endmodule

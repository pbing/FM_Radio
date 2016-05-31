/* Testbench I/Q modulator with filtered I/Q channels. */

module tb_iq_mix_cic;
   timeunit 1ns;
   timeprecision 1fs;

   localparam M = 240;

   const realtime fdev = 75.0e3,                // frequency deviation
                  tcm  = 1s / (100.0e6 + fdev), // carrier frequency with frequency deviation
                  tc   = 1s / 100.0e6,          // unmodulated carrier clock
                  tclk = 1s / (M * 1.0e6);      // sampling clock

   const bit [31:0] K = 2.0**32 * tclk / tc;

   bit                clk;
   bit                adc;
   bit  signed [31:0] phase;
   wire signed [1:0]  I, Q;
   bit                reset;
   bit                clk_1M;
   wire signed [2 + $clog2(M**3) - 1:0] If, Qf;

   iq_modulator dut (.phase(phase[31:30]), .*);

   cic_3_filter
     #(.M    (M),
       .width(2))
   filter_I
     (.reset,
      .clk_in(clk),
      .clk_out(clk_1M),
      .in(I),
      .out(If));

   cic_3_filter
     #(.M    (M),
       .width(2))
   filter_Q
     (.reset,
      .clk_in(clk),
      .clk_out(clk_1M),
      .in(Q),
      .out(Qf));

   always #(tcm/2)   adc = ~adc;
   always #(tclk/2) clk = ~clk;

   always @(posedge clk)
     phase <= phase + K;

   always @(posedge clk)
     begin:clk_gen
        int counter;

        if (counter < M/2)
          clk_1M <= 1'b1;
        else
          clk_1M <= 1'b0;

        if (counter < M - 1)
          counter <= counter + 1;
        else
          counter <= 0;
     end:clk_gen

   initial
     begin:main
        reset = 1'b1;
        @(negedge clk);
        reset = 1'b0;

        #(3 * 1s/fdev) $finish;
     end:main
endmodule

/* Testbench radio_core */


module tb_radio_core;
   timeunit 1ns;
   timeprecision 1fs;

   localparam width_dds    = 32;                // DDS accumulator width
   localparam width_cordic = 17;                // CORDIC width
   localparam M            = 240;               // carrier to broad-band frequency ratio

   const realtime fdev = 75.0e3,                // frequency deviation
                  //tcm  = 1s / (100.0e6 - fdev), // carrier frequency with frequency deviation
                  tcm  = 1s / (100.0e6 + fdev), // carrier frequency with frequency deviation
                  tc   = 1s / 100.0e6,          // unmodulated carrier clock
                  ts   = 1s / (M * 1.0e6);      // sampling clock

   bit                              reset;       // reset
   bit                              clk_s;       // sampling clock
   bit                              clk_b;       // base-band clock
   bit                              adc;         // broadcast signal from 1-bit ADC
   bit         [width_dds - 1:0]    K;           // phase constant for DDS
   wire signed [width_cordic - 1:0] demodulated; // demodulated signal

   radio_core dut(.*);

   always #(tcm/2) adc   = ~adc;
   always #(ts/2)  clk_s = ~clk_s;

   always @(posedge clk_s)
     begin:clk_gen
        int counter;

        if (counter < M/2)
          clk_b <= 1'b1;
        else
          clk_b <= 1'b0;

        if (counter < M - 1)
          counter <= counter + 1;
        else
          counter <= 0;
     end:clk_gen


   initial
     begin:main
        K = 2.0**32 * ts / tc; // tune to carrier frequency

        reset = 1'b1;
        @(negedge clk_s);
        reset = 1'b0;

        #(30 * 1s/fdev) $finish;
     end:main
endmodule

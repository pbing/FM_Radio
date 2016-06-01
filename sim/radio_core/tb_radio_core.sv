/* Testbench radio_core */


module tb_radio_core;
   timeunit 1ns;
   timeprecision 1fs;

   localparam width_dds    = 32;                  // DDS accumulator width
   localparam width_cordic = 17;                  // CORDIC width
   localparam M1           = 250;                 // carrier to broad-band frequency ratio
   localparam M2           = 30;                  // broad-band to audio frequency ratio

   const realtime fdev = 75.0e3,                  // frequency deviation
                  //tcm  = 1s / (100.0e6 - fdev),   // carrier frequency with frequency deviation
                  tcm  = 1s / (100.0e6 + fdev),   // carrier frequency with frequency deviation
                  tc   = 1s / 100.0e6,            // unmodulated carrier clock
                  ts   = 1s / (M1 * M2 * 32.0e3); // sampling clock

   bit                              reset;        // reset
   bit                              clk_s;        // sampling clock
   bit                              clk_b;        // base-band clock
   bit                              clk_a;        // audio clock
   bit                              adc;          // broadcast signal from 1-bit ADC
   bit         [width_dds - 1:0]    K;            // phase constant for DDS
   wire signed [15:0]               demodulated;  // demodulated signal

   radio_core dut(.*);

   always #(tcm/2) adc   = ~adc;
   always #(ts/2)  clk_s = ~clk_s;

   always @(posedge clk_s)
     begin:clk_gen1
        int counter;

        if (counter < M1 / 2)
          clk_b <= 1'b1;
        else
          clk_b <= 1'b0;

        if (counter < M1 - 1)
          counter <= counter + 1;
        else
          counter <= 0;
     end:clk_gen1

   always @(posedge clk_s)
     begin:clk_gen2
        int counter;

        if (counter < M1*M2 / 2)
          clk_a <= 1'b1;
        else
          clk_a <= 1'b0;

        if (counter < M1*M2 - 1)
          counter <= counter + 1;
        else
          counter <= 0;
     end:clk_gen2


   initial
     begin:main
        K = 2.0**32 * ts / tc; // tune to carrier frequency

        reset = 1'b1;
        @(negedge clk_s);
        reset = 1'b0;

        #(30 * 1s/fdev) $finish;
     end:main
endmodule

/* Testbench radio_core */


module tb_radio_core;
   timeunit 1ns;
   timeprecision 1fs;

   localparam width_dds    = 32;                  // DDS accumulator width
   localparam width_cordic = 17;                  // CORDIC width
   localparam R1           = 250;                 // carrier to broad-band frequency ratio
   localparam R1a          = 5;                   // first CIC filter stage
   localparam R1b          = R1 / 5;              // second CIC filter stage
   localparam R2           = 30;                  // broad-band to audio frequency ratio

   const realtime fdev = 75.0e3,                  // frequency deviation
                  //tcm  = 1s / (100.0e6 - fdev),   // carrier frequency with frequency deviation
                  tcm  = 1s / (100.0e6 + fdev),   // carrier frequency with frequency deviation
                  tc   = 1s / 100.0e6,            // unmodulated carrier clock
                  tclk = 1s / (R1 * R2 * 32.0e3); // sampling clock

   bit                              reset;        // reset
   bit                              clk;          // clock
   bit                              en1;          //  48 MHz first CIC filter clock enable
   bit                              en_b;         // 960 kHz base-band clock enable
   bit                              en_a ;        //  32 kHz audio clock enable
   bit                              adc;          // broadcast signal from 1-bit ADC
   bit         [width_dds - 1:0]    K;            // phase constant for DDS
   wire signed [15:0]               demodulated;  // demodulated signal

   radio_core dut(.*);

   always #(tcm/2)  adc = ~adc;
   always #(tclk/2) clk = ~clk;

   always @(posedge clk)
     begin:clk_gen1
        int counter;

        if (counter == R1a - 1)
          begin
             counter <= 0;
             en1     <= 1'b1;
          end
        else
          begin
             counter <= counter + 1;
             en1     <= 1'b0;
          end
     end:clk_gen1

   always @(posedge clk)
     begin:clk_gen2
        int counter;

        if (counter == R1a * R1b - 1)
          begin
             counter <= 0;
             en_b    <= 1'b1;
          end
        else
          begin
             counter <= counter + 1;
             en_b    <= 1'b0;
          end
     end:clk_gen2

   always @(posedge clk)
     begin:clk_gen3
        int counter;

        if (counter == R1 * R2 - 1)
          begin
             counter <= 0;
             en_a    <= 1'b1;
          end
        else
          begin
             counter <= counter + 1;
             en_a    <= 1'b0;
          end
     end:clk_gen3


   initial
     begin:main
        K = 2.0**32 * tclk / tc; // tune to carrier frequency

        reset = 1'b1;
        @(negedge clk);
        reset = 1'b0;

        #(30 * 1s/fdev) $finish;
     end:main
endmodule

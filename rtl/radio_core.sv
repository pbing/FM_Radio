/* Radio core */

module radio_core
  #(parameter width_dds    = 32,                            // DDS accumulator width
    parameter width_cordic = 17,                            // CORDIC width
    parameter R1           = 250,                           // carrier to broad-band frequency ratio
    parameter R2           = 30)                            // broad-band to audio frequency ratio
   (input  wire                             reset,          // reset
    input  wire                             clk,            // clock
    input  wire                             en1,            //  48 MHz first CIC filter clock enable
    input  wire                             en_b,           // 960 kHz base-band clock enable
    input  wire                             en_a,           //  32 kHz audio clock enable
    input  wire                             adc,            // broadcast signal from 1-bit ADC
    input  wire        [width_dds - 1:0]    K,              // phase constant for DDS
    output wire signed [15:0]               demodulated);   // demodulated signal

   localparam R1a = 5;      // first CIC filter stage
   localparam R1b = R1 / 5; // second CIC filter stage

   wire                                                    adc_s;    // synchronized broadcast signal from 1-bit ADC
   wire signed [width_dds - 1:0]                           phase;    // DDS phase
   wire signed [1:0]                                       I, Q;     // I/Q
   wire signed [2 + $clog2(R1a**3) - 1:0]                  If1, Qf1; // filtered I/Q, first stage
   wire signed [2 + $clog2(R1a**3) + $clog2(R1b**3) - 1:0] If2, Qf2; // filtered I/Q, second stage
   wire signed [width_cordic - 1:0]                    cordic_phase; // CORDIC phase
   wire signed [width_cordic - 1:0]              differentiator_out; // differentiator output
   wire signed [width_cordic + $clog2(R2**3) - 1:0]   demodulated_f; // filtered demodulated

   /**************************************************
    * DDS
    **************************************************/

   dds
     #(.width(width_dds))
   inst_dds
     (.reset,
      .clk(clk),
      .K,
      .phase);

   /**************************************************
    * Carrier to I/Q conversion
    **************************************************/

   synchronizer sync_adc
     (.reset,
      .clk(clk),
      .en(1'b1),
      .in (adc),
      .out(adc_s));

   iq_modulator inst_iq_modulator
     (.clk  (clk),
      .adc  (adc_s),
      .phase(phase[$left(phase)-:2]),
      .I,
      .Q);

   /**************************************************
    * Base-band filters
    **************************************************/

   /* firt stage */
   cic_3_filter
     #(.R    (R1a),
       .width($bits(I)))
   filter_I1
     (.reset,
      .clk   (clk),
      .en_in (1'b1),
      .en_out(en1),
      .in    (I),
      .out   (If1));

   cic_3_filter
     #(.R    (R1a),
       .width($bits(Q)))
   filter_Q1
     (.reset,
      .clk   (clk),
      .en_in (1'b1),
      .en_out(en1),
      .in    (Q),
      .out   (Qf1));

   /* second stage */
   cic_3_filter
     #(.R    (R1b),
       .width($bits(If1)))
   filter_I2
     (.reset,
      .clk   (clk),
      .en_in (en1),
      .en_out(en_b),
      .in    (If1),
      .out   (If2));

   cic_3_filter
     #(.R    (R1b),
       .width($bits(Qf1)))
   filter_Q2
     (.reset,
      .clk   (clk),
      .en_in (en1),
      .en_out(en_b),
      .in    (Qf1),
      .out   (Qf2));

   /**************************************************
    * Frequency detector
    **************************************************/

   /* Connect x0/y0 with double magnitude of If/Qf in order to
    * compensate the conversion gain of 1/2.
    * This improves the S/N ratio of the CORDIC unit.
    */
   cordic
     #(.vectoring(1),
       .width    (width_cordic))
   inst_cordic
     (.reset,
      .clk(clk),
      .en(en_b),
      .x0 (If2[$left(If2) - 1 -: width_cordic]),
      .y0 (Qf2[$left(Qf2) - 1 -: width_cordic]),
      .z0 ('0),
      .x  (/*open*/),
      .y  (/*open*/),
      .z  (cordic_phase));

   differentiator
     #(.width(width_cordic))
   inst_differentiator
     (.reset,
      .clk(clk),
      .en(en_b),
      .in(cordic_phase),
      .out(differentiator_out));

   /**************************************************
    * Audio filters
    **************************************************/

   cic_3_filter
     #(.R    (R2),
       .width(width_cordic))
   filter_audio
     (.reset,
      .clk   (clk),
      .en_in (en_b),
      .en_out(en_a),
      .in    (differentiator_out),
      .out   (demodulated_f));

   /* Compensate gain loss by multiplication with four. */
   assign demodulated = demodulated_f[$left(demodulated_f) - 2 -: 16];
endmodule

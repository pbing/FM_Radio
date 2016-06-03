/* Radio core */

module radio_core
  #(parameter width_dds    = 32,                            // DDS accumulator width
    parameter width_cordic = 17,                            // CORDIC width
    parameter R1           = 250,                           // carrier to broad-band frequency ratio
    parameter R2           = 30)                            // broad-band to audio frequency ratio
   (input  wire                             reset,          // reset
    input  wire                             clk,            // clock
    input  wire                             en_b,           // 960 kHz base-band clock enable
    input  wire                             en_a,           //  32 kHz audio clock enable
    input  wire                             adc,            // broadcast signal from 1-bit ADC
    input  wire        [width_dds - 1:0]    K,              // phase constant for DDS
    output wire signed [15:0]               demodulated);   // demodulated signal

   wire                                 adc_s;              // synchronized broadcast signal from 1-bit ADC
   wire signed [width_dds - 1:0]        phase;              // DDS phase
   wire signed [1:0]                    I, Q;               // I/Q
   wire signed [2 + $clog2(R1**3) - 1:0] If, Qf;            // filtered I/Q
   wire signed [width_cordic - 1:0]     cordic_phase;       // CORDIC phase
   wire signed [width_cordic - 1:0]     differentiator_out; // differentiator output
   wire signed [width_cordic + $clog2(R2**3) - 1:0] demodulated_f; // filtered demodulated

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

   cic_3_filter
     #(.R    (R1),
       .width(2))
   filter_I
     (.reset,
      .clk   (clk),
      .en_in (1'b1),
      .en_out(en_b),
      .in    (I),
      .out   (If));

   cic_3_filter
     #(.R    (R1),
       .width(2))
   filter_Q
     (.reset,
      .clk   (clk),
      .en_in (1'b1),
      .en_out(en_b),
      .in    (Q),
      .out   (Qf));

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
      .x0 (If[$left(If) - 1 -: width_cordic]),
      .y0 (Qf[$left(Qf) - 1 -: width_cordic]),
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

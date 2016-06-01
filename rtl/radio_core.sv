/* Radio core */

module radio_core
  #(parameter width_dds    = 32,                          // DDS accumulator width
    parameter width_cordic = 17,                          // CORDIC width
    parameter M            = 240)                         // carrier to broad-band frequency ratio
   (input  wire                             reset,        // reset
    input  wire                             clk_s,        // sampling clock
    input  wire                             clk_b,        // base-band clock
    input  wire                             adc,          // broadcast signal from 1-bit ADC
    input  wire        [width_dds - 1:0]    K,            // phase constant for DDS
    output wire signed [width_cordic - 1:0] demodulated); // demodulated signal

   wire                                 adc_s;            // synchronized broadcast signal from 1-bit ADC
   bit  signed [width_dds - 1:0]        phase;            // DDS phase
   wire signed [1:0]                    I, Q;             // I/Q
   wire signed [2 + $clog2(M**3) - 1:0] If, Qf;           // filtered I/Q
   wire signed [width_cordic - 1:0]     cordic_phase;     // CORDIC phase

   dds
     #(.width(width_dds))
   inst_dds
     (.reset,
      .clk(clk_s),
      .K,
      .phase);

   synchronizer sync_adc
     (.reset,
      .clk(clk_s),
      .in (adc),
      .out(adc_s));

   iq_modulator inst_iq_modulator
     (.clk  (clk_s),
      .adc  (adc_s),
      .phase(phase[$left(phase)-:2]),
      .I,
      .Q);

   cic_3_filter
     #(.M    (M),
       .width(2))
   filter_I
     (.reset,
      .clk_in (clk_s),
      .clk_out(clk_b),
      .in     (I),
      .out    (If));

   cic_3_filter
     #(.M    (M),
       .width(2))
   filter_Q
     (.reset,
      .clk_in (clk_s),
      .clk_out(clk_b),
      .in     (Q),
      .out    (Qf));

   cordic
     #(.vectoring(1),
       .width    (width_cordic))
   inst_cordic
     (.reset,
      .clk(clk_b),
      .x0 (If[$left(If) -: width_cordic]),
      .y0 (Qf[$left(Qf) -: width_cordic]),
      .z0 ('0),
      .x  (/*open*/),
      .y  (/*open*/),
      .z  (cordic_phase));

   differentiator
     #(.width(width_cordic))
   inst_differentiator
     (.reset,
      .clk(clk_b),
      .in(cordic_phase),
      .out(demodulated));

endmodule

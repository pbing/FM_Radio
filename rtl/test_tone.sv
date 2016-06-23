/* Generate a test tone */

module test_tone
   (input  wire        reset, // reset
    input  wire        clk,   // clock
    input  wire        en,    // clock enable ( 32 kHz)
    output wire [15:0] data); // audio data

   localparam cordic_width = 17;                  // use the same atan()-table like in 'radio_core'

   const bit [31:0] K = 2.0**32 * 12.25e3 / 32.0e3; // 1 kHz;

   wire signed [cordic_width - 1:0] x0, y0, z0;
   wire signed [cordic_width    :0] x;            // output (scaled with K=1.6467...)

   logic [31:0] phase;

   assign x0   = 2**(cordic_width - 1) - 1 ;
   assign y0   = 0;
   assign z0   = phase[31 -: cordic_width];
   assign data = x[cordic_width -: 16];

      cordic
     #(.vectoring(0),
       .width    (cordic_width))
   inst_cordic
     (.reset,
      .clk,
      .en,
      .x0,
      .y0,
      .z0,
      .x,
      .y(/*open*/),
      .z(/*open*/));

   /* phase accumulator */
   always @(posedge clk or posedge reset)
     if (reset)
       phase <= 0;
     else
       if (en)
         phase <= phase + K;
endmodule

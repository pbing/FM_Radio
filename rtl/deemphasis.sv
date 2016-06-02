/* De-emphasis low-pass filter with 50 µs time constant.
 * Pipelined.
 *
 * Implemented with impulse invariant method.
 */

/* FIXME: Create RTL model. */
module deemphasis
  #(parameter width)
   (input  wire                       reset, // reset
    input  wire                       clk,   // clock
    input  wire  signed [width - 1:0] in,    // input
    output logic signed [width - 1:0] out);  // filtered result

   const real a = $exp(-(1.0 / (50.0e-6 * 32.0e3))),
              b = 1.0 - a;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       out <= '0;
     else
       out <= out * a + in * b;
endmodule

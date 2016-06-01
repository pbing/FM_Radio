/* De-emphasis low-pass filter with 50 µs time constant.
 * Pipelined.
 * 
 * Implemented with impulse invariant method.
 */

module deemphasis
  #(parameter width)
  (input  wire               reset, // reset
   input  wire               clk,   // clock
   input  wire [width - 1:0] in,    // input
   output wire [width - 1:0] out);  // filtered result

   const real a = 0.535261, b = 0.464739;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       out <= '0;
     else
       out <= out * a + in * b;
endmodule

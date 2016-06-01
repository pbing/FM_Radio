/* Differentiator, converts phase to frequency */

module differentiator
  #(parameter width)
   (input  wire                       reset, // reset
    input  wire                       clk,   // clk,
    input  wire  signed [width - 1:0] in,    // data input
    output logic signed [width - 1:0] out);  // data output

   logic signed [width - 1:0] in1;          // delayed data input

   always_ff @(posedge clk or posedge reset)
     if (reset)
       in1 <= '0;
     else
       in1 <= in;

   always_comb out = in - in1;
endmodule

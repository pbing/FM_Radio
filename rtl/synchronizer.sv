/* Synchronizer */

module synchronizer
  (input  wire reset, // reset
   input  wire clk,   // clock
   input  wire in,    // input
   output wire out);  // synchronized output

   logic [1:3] sync;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       sync <= '0;
     else
       sync <= {in, sync[1 : $right(sync) - 1]};

   assign out = sync[3];
endmodule

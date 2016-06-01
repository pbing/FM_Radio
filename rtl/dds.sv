/* Direct Digital Synthesis (DDS) */

module dds
  #(parameter width)
   (input wire                          reset,  // reset
    input wire                          clk,    // clock
    input wire          [width - 1 : 0] K,      // phase constant
    output logic signed [width - 1 : 0] phase); // phase (-π ... π)

   always_ff @(posedge clk or posedge reset)
     if (reset)
       phase <= '0;
     else
       phase <= phase + K;
endmodule

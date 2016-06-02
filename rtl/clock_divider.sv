/* Generic clock divider */

module clock_divider
  #(parameter M)         // divider ratio
   (input  wire  reset,  // reset
    input  wire  clk,    // input clock
    output logic clk_o); // output clock

   logic [$clog2(M) - 1 : 0] counter;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       begin
          counter <= '0;
          clk_o   <= 1'b0;
       end
     else
       if (counter == M/2 - 1)
         begin
            counter <= counter + 1;
            clk_o   <= 1'b0;
         end
       else if (counter == M - 1)
         begin
            counter <= '0;
            clk_o   <= 1'b1;
         end
       else
         counter <= counter + 1;
endmodule

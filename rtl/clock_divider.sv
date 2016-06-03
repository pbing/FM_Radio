/* Generic clock divider */

module clock_divider
  #(parameter M)         // divider ratio
   (input  wire  reset,  // reset
    input  wire  clk,    // input clock
    input  wire  en_i,   // input enable enable
    output logic en_o);  // output clock enable

   logic [$clog2(M) - 1 : 0] counter;
   logic                     en;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       begin
          counter <= '0;
          en   <= 1'b0;
       end
     else
       if (en_i)
         if (counter == M - 1)
           begin
              counter <= '0;
              en   <= 1'b1;
           end
         else
           begin
              counter <= counter + 1;
              en      <= 1'b0;
           end

   always_comb en_o = en_i & en;
endmodule

/* Clock unit */

module clock_unit
  #(parameter M1 = 250,  // carrier to broad-band frequency ratio
    parameter M2 = 30)   // broad-band to audio frequency ratio
   (input  wire  reset,  // reset
    input  wire  clk_s,  // 240 MHz sampling clock
    output logic clk_b,  // 960 kHz base-band clock
    output logic clk_a); //  32 kHz audio clock

   logic [$clog2(M1) - 1 : 0] counter1;
   logic [$clog2(M2) - 1 : 0] counter2;

   /* base-band clock generator */
   always_ff @(posedge clk_s or posedge reset)
     if (reset)
       begin
          counter1 <= '0;
          clk_b    <= 1'b0;
       end
     else
       if (counter1 == M1/2 - 1)
         begin
            counter1 <= counter1 + 1;
            clk_b    <= 1'b0;
         end
       else if (counter1 == M1 - 1)
         begin
            counter1 <= '0;
            clk_b    <= 1'b1;
         end
       else
         counter1 <= counter1 + 1;

   /* audio clock generator */
   always_ff @(posedge clk_b or posedge reset)
     if (reset)
       begin
          counter2 <= '0;
          clk_a    <= 1'b0;
       end
     else
       if (counter2 == M2/2 - 1)
         begin
            counter2 <= counter2 + 1;
            clk_a    <= 1'b0;
         end
       else if (counter2 == M2 - 1)
         begin
            counter2 <= '0;
            clk_a    <= 1'b1;
         end
       else
         counter2 <= counter2 + 1;
endmodule

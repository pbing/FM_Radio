/* Reset unit */

module reset_unit
  (input  wire  clk_s,        // sampling clock
   input  wire  clk_b,        // base-band clock
   input  wire  clk_a,        // audio clock
   input  wire  reset_in,     // external reset
   output logic reset_out_s,  // reset sampling clock domain
   output logic reset_out_b,  // reset base-band clock domain
   output logic reset_out_a); // audio clock domain

   wire reset_s_n, reset_b, reset_a_n;

   synchronizer synchronizer_s
     (.reset(reset_in),
      .clk  (clk_s),
      .in   (1'b1),
      .out  (reset_s_n));

   synchronizer synchronizer_b
     (.reset(reset_in),
      .clk  (clk_b),
      .in   (1'b1),
      .out  (reset_b_n));

   synchronizer synchronizer_a
     (.reset(reset_in),
      .clk  (clk_a),
      .in   (1'b1),
      .out  (reset_a_n));

   always_comb
     begin
        reset_out_s = ~reset_s_n;
        reset_out_b = ~reset_b_n;
        reset_out_a = ~reset_a_n;
     end
endmodule

/* Pipelined decimating Cascaded Integrator-Comb (CIC) filter of order 3. */

module cic_3_filter
  #(parameter M,
    parameter width)
   (input  wire                                       reset,   // reset
    input  wire                                       clk_in,  // clock
    input  wire                                       clk_out, // decimated clock
    input  wire signed [width - 1                : 0] in,      // input
    output wire signed [width + $clog2(M**3) - 1 : 0] out);    // filtered and decimated output

   logic signed [width + $clog2(M**3) - 1 : 0] i_del[3], d_del[3], d_dif[3];

   /* integrator section */
   always_ff @(posedge clk_in or posedge reset)
     if (reset)
       begin
          i_del[0] <= '0;
          i_del[1] <= '0;
          i_del[2] <= '0;
       end
     else
       begin
          i_del[0] <= in       + i_del[0];
          i_del[1] <= i_del[0] + i_del[1];
          i_del[2] <= i_del[1] + i_del[2];
       end

   /* differentiator section */
   always_ff @(posedge clk_out or posedge reset)
     if (reset)
       begin
          d_dif[0] <= '0;
          d_dif[1] <= '0;
          d_dif[2] <= '0;

          d_del[0] <= '0;
          d_del[1] <= '0;
          d_del[2] <= '0;
       end
     else
       begin
          d_dif[0] <= i_del[2] - d_del[0];
          d_dif[1] <= d_dif[0] - d_del[1];
          d_dif[2] <= d_dif[1] - d_del[2];

          d_del[0] <= i_del[2];
          d_del[1] <= d_dif[0];
          d_del[2] <= d_dif[1];
       end

   assign out = d_dif[2];
endmodule

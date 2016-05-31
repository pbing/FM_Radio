module tb_cic_3_filter;
   timeunit 1ns;
   timeprecision 1ps;

   localparam M     = 10;
   localparam width = 11;

   const realtime tclk_in = 1s/250e6;

   bit                                        reset;
   bit                                        clk_in;
   bit                                        clk_out;
   bit  signed [width - 1 : 0]                in;
   wire signed [width + $clog2(M**3) - 1 : 0] out;

   cic_3_filter
     #(.M    (M),
       .width(width))
   dut(.*);

   always #(tclk_in/2)  clk_in  = ~clk_in;

   always @(posedge clk_in)
     begin:clk_gen
        int counter;

        if (counter < M/2)
          clk_out <= 1'b1;
        else
          clk_out <= 1'b0;

        if (counter < M - 1)
          counter <= counter + 1;
        else
          counter <= 0;
     end:clk_gen

   initial
     begin:main
        reset = 1'b1;
        @(negedge clk_out);
        reset = 1'b0;

        @(posedge clk_out);
        in <= 'sd1000;
        repeat (2 * 3 * M) @(posedge clk_out);

        in <= -'sd1000;
        repeat (2 * 3 * M) @(posedge clk_out);

        in <= 'sd0;
        repeat (2 * 3 * M) @(posedge clk_out);

        $finish;
     end:main
endmodule

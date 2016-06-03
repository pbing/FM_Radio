module tb_cic_3_filter;
   timeunit 1ns;
   timeprecision 1ps;

   localparam R     = 5; // decimation ratio
   localparam width = 2; // input data width

   const realtime tclk = 1s/250e6;

   bit                                        reset;         // reset
   bit                                        clk;           // clock
   const bit                                  en_in = 1'b1;  // clock enable input
   bit                                        en_out;        // clock enable output
   bit  signed [width - 1 : 0]                in;            // input
   wire signed [width + $clog2(R**3) - 1 : 0] out;           // filtered and decimated outpu

   cic_3_filter
     #(.R    (R),
       .width(width))
   dut(.*);

   always #(tclk/2)  clk  = ~clk;

   always @(posedge clk)
     begin:clk_gen
        int counter;

        if (counter == R - 1)
          begin
             counter <= 0;
             en_out  <= 1'b1;
          end
        else
          begin
             counter <= counter + 1;
             en_out  <= 1'b0;
          end
     end:clk_gen

   initial
     begin:main
        reset = 1'b1;
        @(negedge clk);
        reset = 1'b0;

        @(posedge clk);
        in <= 1;
        repeat (2 * 3 * R) @(posedge clk);
        assert (out == R**3 * in);

        in <= -1;
        repeat (2 * 3 * R) @(posedge clk);
        assert (out == R**3 * in);

        in <= 0;
        repeat (2 * 3 * R) @(posedge clk);
        assert (out == R**3 * in);

        $finish;
     end:main
endmodule

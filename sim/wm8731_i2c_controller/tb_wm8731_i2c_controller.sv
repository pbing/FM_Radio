/* Testbench WM8731 I2C controller */

module tb_wm8731_i2c_controller;
   timeunit 1ns;
   timeprecision 1ps;

   bit            reset; // reset
   bit            clk;   // clock
   bit            en;    // clock enable (4 times bit clock rate)
   bit [6:0]      addr;  // address
   bit [1:0][7:0] wdata; // write data
   bit            req;   // request
   wire           ack;   // acknowledge
   tri1           SCL;   // I2C clock
   tri1           SDA;   // I2C data

   const real tclk240m = 1s / 240.0e6;
   const int  M = 240000000 / (4 * 400000); // SCL = 400 kHz

   wm8731_i2c_controller dut(.*);

   always #(tclk240m/2) clk = ~clk;

   always @(posedge clk)
     if (reset)
       en <= 1'b0;
     else
       begin
          repeat (M  - 1) @(posedge clk);
          en <= 1'b1;
          @(posedge clk);
          en <= 1'b0;
       end

   initial
     begin:main
        reset = 1'b1;
        repeat (2) @(negedge clk);
        reset = 1'b0;

        repeat (5)
          begin
             #100us;
             while (!en) @(posedge clk);
             addr  = $random;
             wdata = $random;
             req   = 1'b1;

             while (en) @(posedge clk);
             while (!en) @(posedge clk);
             req = 1'b0;

             while (!ack) @(posedge clk);
          end

        #100ns $finish;
     end:main
endmodule

/* Testbench WM8731 controller */

module tb_wm8731_controller;
   timeunit 1ns;
   timeprecision 1ps;

   const real tclk240m = 1s / 240.0e6;

   wire        reset;     // reset
   bit         clk;       // 240 MHz clock
   wire        en48m;     // 48 MHz clock enable
   wire        en32k;     // 48 MHz clock enable
   bit  [15:0] audio_dat; // audio data
   wire        i2c_scl;   // I2C SCL
   wire        i2c_sda;   // I2C DAT
   wire        dac_lr_ck; // DAC L/R clock
   wire        dac_dat;   // DAC data
   wire        bclk;      // 1.024 MHz BCLK
   wire        mclk;      // 12 MHz MCLK

   bit         reset_in;

   wm8731_controller dut(.*);

   cru inst_cru
     (.reset_in,
      .reset_sync(reset),
      .clk240m   (clk),
      .en48m,
      .en960k    (/*open*/),
      .en32k);


   always #(tclk240m/2) clk = ~clk;

   always @(posedge clk)
     if (en32k)
       audio_dat <= $random;

   initial
     begin:main
        reset_in = 1'b1;
        #10ns;
        reset_in = 1'b0;

        #200us $finish;
     end:main
endmodule


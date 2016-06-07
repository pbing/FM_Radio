/* WM8731 controller */

module wm8731_controller
  (input  wire  reset,            // reset
   input  wire  clk,              // 24 MHz clock
   input  wire  [15:0] audio_dat, // audio data
   output wire  i2c_scl,          // I2C SCL
   output wire  i2c_sda,          // I2C DAT
   output wire  dac_lr_ck,        // DAC L/R clock
   output wire  dac_dat,          // DAC data
   output wire  bclk,             // < 20 MHz BCLK
   output logic mclk);            // 12 MHz MCLK

   /* MCLK generator for DAC */
   always_ff @(posedge clk or posedge reset)
     if (reset_out)
       mclk <= 1'b0;
     else
       mclk <= ~mclk;

   // FIXME
   assign dac_dat = ^audio_dat; // prevent optimization
endmodule

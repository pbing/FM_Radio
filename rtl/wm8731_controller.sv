/* WM8731 controller */

module wm8731_controller
  (input  wire        reset,     // reset
   input  wire        clk,       // 240 MHz clock
   input  wire        en48m,     //  48 MHz clock enable
   input  wire        en32k,     //  32 kHz clock enable
   input  wire [15:0] audio_dat, // audio data
   output wire        i2c_scl,   // I2C SCL
   output wire        i2c_sda,   // I2C DAT
   output wire        dac_lr_ck, // DAC L/R clock
   output wire        dac_dat,   // DAC data
   output wire        bclk,      // 1.024 MHz BCLK
   output wire        mclk);     // 12 MHz MCLK

   wire            en1m6; // 1.6 MHz = 4 * 400 kHz
   wire [6:0]      addr;  // address
   wire [1:0][7:0] wdata; // write data
   wire            req;   // request
   wire            ack;   // acknowledge
   
   wm8731_i2c_controller inst_i2c_controller
     (.reset,
      .clk,
      .en(en1m6),
      .addr,
      .wdata,
      .req,
      .ack,
      .SCL(i2c_scl),
      .SDA(i2c_sda));

   wm8731_serializer inst_serializer
     (.reset,
      .clk,
      .en48m,
      .en32k,
      .audio_dat,
      .dac_lr_ck,
      .dac_dat,
      .bclk,
      .mclk);
endmodule

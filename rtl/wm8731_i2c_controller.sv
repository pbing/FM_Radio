/* I2C controller for WM7131 */

module wm8731_i2c_controller
  (input  wire        reset,     // reset
   input  wire        clk,       // 240 MHz clock
   output wire        i2c_scl,   // I2C SCL
   output wire        i2c_sda);  // I2C DAT

   assign i2c_scl = 1'b1;
   assign i2c_sda = 1'b0;
endmodule

/* Clock and reset unit (CRU) */

module cru
  (input  wire reset_in,   // power-on reset
   output wire reset_sync, // synchronized reset
   input  wire clk240m,    // 240 MHz clock
   output wire en48m,      //  48 MHz clock enable
   output wire en1m6,      // 1.6 MHz clock enable
   output wire en960k,     // 960 kHz clock enable
   output wire en32k);     //  32 kHz clock enable

   wire reset_sync_n;

   /* reset synchronization */
   synchronizer inst_reset_sync
     (.reset(reset_in),
      .clk  (clk240m),
      .en   (1'b1),
      .in   (1'b1),
      .out  (reset_sync_n));

   assign reset_sync = ~reset_sync_n;

   /* 1st CIC filter clock */
   clock_divider
     #(.M(5))
   inst_clk48m
     (.reset(reset_sync),
      .clk  (clk240m),
      .en_i (1'b1),
      .en_o (en48m));

   /* 4 times I2C clock */
   clock_divider
     #(.M(30))
   inst_clk1m6
     (.reset(reset_sync),
      .clk  (clk240m),
      .en_i (en48m),
      .en_o (en1m6));

   /* base-band clock */
   clock_divider
     #(.M(50))
   inst_clk960k
     (.reset(reset_sync),
      .clk  (clk240m),
      .en_i (en48m),
      .en_o (en960k));

   /* audio clock */
   clock_divider
     #(.M(30))
   inst_clk32k
     (.reset(reset_sync),
      .clk  (clk240m),
      .en_i (en960k),
      .en_o (en32k));
endmodule

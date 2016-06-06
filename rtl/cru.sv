/* Clock and reset unit (CRU) */

module cru
  (input  wire reset_in,  // power-on reset
   output wire reset_out, // synchronized reset

   input  wire clk240m,   // 240 MHz clock

   output wire en48m,     //  48 MHz clock enable
   output wire en960k,    // 960 kHz clock enable
   output wire en32k);    //  32 kHz clock enable

   wire reset_out_n;

   /* reset synchronization */
   synchronizer inst_reset_out
     (.reset(reset_in),
      .clk  (clk240m),
      .en   (1'b1),
      .in   (1'b1),
      .out  (reset_out_n));

   assign reset_out = ~reset_out_n;

   /* base-band clock */
   clock_divider
     #(.M(5))
   inst_clk48m
     (.reset(reset_out),
      .clk  (clk240m),
      .en_i (1'b1),
      .en_o (en48m));

   clock_divider
     #(.M(50))
   inst_clk960k
     (.reset(reset_out),
      .clk  (clk240m),
      .en_i (en48m),
      .en_o (en960k));

   /* audio clock */
   clock_divider
     #(.M(30))
   inst_clk32k
     (.reset(reset_out),
      .clk  (clk240m),
      .en_i (en960k),
      .en_o (en32k));
endmodule

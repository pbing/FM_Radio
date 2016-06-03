/* Clock and reset unit (CRU) */

module cru
  (input  wire reset_in, // power-on reset
   output wire rst240m,  // 240 MHz clock domain
   output wire rst960k,  // 960 kHz clock domain
   output wire rst32k,   //  32 kHz clock domain

   input  wire clk240m,  // 240 MHz clock

   output wire en960k,   // 960 kHz clock enable
   output wire en32k);   //  32 kHz clock enable

   wire rst240m_n;
   wire rst960k_n;
   wire rst32k_n;

   synchronizer inst_rst240m
     (.reset(reset_in),
      .clk  (clk240m),
      .en   (1'b1),
      .in   (1'b1),
      .out  (rst240m_n));

   synchronizer inst_rst960k
     (.reset(reset_in),
      .clk  (clk240m),
      .en   (en960k),
      .in   (1'b1),
      .out  (rst960k_n));

   synchronizer inst_rst32k
     (.reset(reset_in),
      .clk  (clk240m),
      .en   (en32k),
      .in   (1'b1),
      .out  (rst32k_n));

   assign rst240m = ~rst240m_n;
   assign rst960k = ~rst960k_n;
   assign rst32k  = ~rst32k_n;

   /* base-band clock */
   clock_divider
     #(.M(250))
   inst_clk960k
     (.reset(rst240m),
      .clk  (clk240m),
      .en_i (1'b1),
      .en_o (en960k));

   /* audio clock */
   clock_divider
     #(.M(30))
   inst_clk32k
     (.reset(rst960k),
      .clk  (clk240m),
      .en_i (en960k),
      .en_o (en32k));
endmodule

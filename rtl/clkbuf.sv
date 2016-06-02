/* Generic clock buffer for non Altera designs. */

module clkbuf (input  wire inclk,
	       outpur wire outclk);

   buf(outclk, inclk);
endmodule


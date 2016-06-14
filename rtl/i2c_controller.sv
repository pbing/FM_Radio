/* I²C Controller (write only) */

/*
 counter 00000123012301230123...01230123
 state   IIIISSSS666655554444...AAAAPPPP
 req     LLLHL...
 SCL     11111110011001100110...01100011
 SDA     11111100666655554444...aaaa0111
 */

module i2c_controller
  (input  wire            reset, // reset
   input  wire            clk,   // clock
   input  wire            en,    // clock enable (4 times bit clock rate)
   input  wire [6:0]      addr,  // address
   input  wire [1:0][7:0] wdata, // write data
   input  wire            req,   // request
   output logic           ack,   // acknowledge
   output logic           SCL,   // I2C clock
   output logic           SDA);  // I2C data

   logic [1:0] counter;
   enum int unsigned {IDLE, START, A[7], RW, ACK[3], D[16], STOP} state, next;

   /* bit counter */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       counter <= 2'd0;
     else
       if (en)
         if (state == IDLE)
           counter <= 2'd0;
         else
           counter <= counter + 2'd1;

   /* FSM */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       state <= IDLE;
     else
       if (req || counter == 2'd3)
         state <= next;

   always_comb
     case (state)
       IDLE:
         begin
            SDA = 1'b1;

            if (req)
              next = START;
            else
              next = IDLE;
         end

       START:
         begin
            if (counter == 2'd3)
              SDA = 1'b0;
            else
              SDA = 1'b1;

            next = A6;
         end

       A6   : begin SDA = addr[6];     next = A5;   end
       A5   : begin SDA = addr[5];     next = A4;   end
       A4   : begin SDA = addr[4];     next = A3;   end
       A3   : begin SDA = addr[3];     next = A2;   end
       A2   : begin SDA = addr[2];     next = A1;   end
       A1   : begin SDA = addr[1];     next = A0;   end
       A0   : begin SDA = addr[0];     next = RW;   end
       RW   : begin SDA = 1'b0;        next = ACK0; end
       ACK0 : begin SDA = 1'b1;        next = D15;  end
       D15  : begin SDA = wdata[1][7]; next = D14   end
       D14  : begin SDA = wdata[1][6]; next = D13   end
       D13  : begin SDA = wdata[1][5]; next = D12   end
       D12  : begin SDA = wdata[1][4]; next = D11   end
       D11  : begin SDA = wdata[1][3]; next = D10   end
       D10  : begin SDA = wdata[1][2]; next = D9;   end
       D9   : begin SDA = wdata[1][1]; next = D8;   end
       D8   : begin SDA = wdata[1][0]; next = ACK1; end
       ACK1 : begin SDA = 1'b1;        next = D7;   end
       D7   : begin SDA = wdata[0][7]; next = D6;   end
       D6   : begin SDA = wdata[0][6]; next = D5;   end
       D5   : begin SDA = wdata[0][5]; next = D4;   end
       D4   : begin SDA = wdata[0][4]; next = D3;   end
       D3   : begin SDA = wdata[0][3]; next = D2;   end
       D2   : begin SDA = wdata[0][2]; next = D1;   end
       D1   : begin SDA = wdata[0][1]; next = D0;   end
       D0   : begin SDA = wdata[0][0]; next = ACK2; end
       ACK2 : begin SDA = 1'b1;        next = STOP; end

       STOP:
         begin
            if (counter == 2'd0)
              SDA = 1'b0;
            else
              SDA = 1'b1;

            next = IDLE;
         end
     endcase

   /* SCL generator */
   always_clock @(posedge clk or posedge reset)
     if (reset)
       SCL <= 1'b1;
     else
       if (en)
         case (state)
           IDLE:
             SCL <= 1'b1;

           STOP:
             if (counter == 2'd0)
               SCL <= 1'b0;
             else
               SCL <= 1'b1;

           default
             if (counter == 2'd2 || counter == 2'd3)
               SCL <= 1'b0;
             else
               SCL <= 1'b1;
         endcase
endmodule

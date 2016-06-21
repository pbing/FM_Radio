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
           /* Gray coded */
           case (counter)
             2'd0: counter <= 2'd1;
             2'd1: counter <= 2'd3;
             2'd3: counter <= 2'd2;
             2'd2: counter <= 2'd0;
           endcase

   /* FSM */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       state <= IDLE;
     else
       if (en)
         state <= next;

   always_comb
     begin
        ack  = 1'b0;
        next = state;

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
               if (counter == 2'd3 || counter == 2'd2)
                 SDA = 1'b0;
               else
                 SDA = 1'b1;

               if (counter == 2'd2) next = A6;
            end

          A6   : begin SDA = addr[6];     if (counter == 2'd2) next = A5;   end
          A5   : begin SDA = addr[5];     if (counter == 2'd2) next = A4;   end
          A4   : begin SDA = addr[4];     if (counter == 2'd2) next = A3;   end
          A3   : begin SDA = addr[3];     if (counter == 2'd2) next = A2;   end
          A2   : begin SDA = addr[2];     if (counter == 2'd2) next = A1;   end
          A1   : begin SDA = addr[1];     if (counter == 2'd2) next = A0;   end
          A0   : begin SDA = addr[0];     if (counter == 2'd2) next = RW;   end
          RW   : begin SDA = 1'b0;        if (counter == 2'd2) next = ACK0; end
          ACK0 : begin SDA = 1'b1;        if (counter == 2'd2) next = D15;  end
          D15  : begin SDA = wdata[1][7]; if (counter == 2'd2) next = D14;  end
          D14  : begin SDA = wdata[1][6]; if (counter == 2'd2) next = D13;  end
          D13  : begin SDA = wdata[1][5]; if (counter == 2'd2) next = D12;  end
          D12  : begin SDA = wdata[1][4]; if (counter == 2'd2) next = D11;  end
          D11  : begin SDA = wdata[1][3]; if (counter == 2'd2) next = D10;  end
          D10  : begin SDA = wdata[1][2]; if (counter == 2'd2) next = D9;   end
          D9   : begin SDA = wdata[1][1]; if (counter == 2'd2) next = D8;   end
          D8   : begin SDA = wdata[1][0]; if (counter == 2'd2) next = ACK1; end
          ACK1 : begin SDA = 1'b1;        if (counter == 2'd2) next = D7;   end
          D7   : begin SDA = wdata[0][7]; if (counter == 2'd2) next = D6;   end
          D6   : begin SDA = wdata[0][6]; if (counter == 2'd2) next = D5;   end
          D5   : begin SDA = wdata[0][5]; if (counter == 2'd2) next = D4;   end
          D4   : begin SDA = wdata[0][4]; if (counter == 2'd2) next = D3;   end
          D3   : begin SDA = wdata[0][3]; if (counter == 2'd2) next = D2;   end
          D2   : begin SDA = wdata[0][2]; if (counter == 2'd2) next = D1;   end
          D1   : begin SDA = wdata[0][1]; if (counter == 2'd2) next = D0;   end
          D0   : begin SDA = wdata[0][0]; if (counter == 2'd2) next = ACK2; end
          ACK2 : begin SDA = 1'b1;        if (counter == 2'd2) next = STOP; end

          STOP:
            begin
               if (counter == 2'd0 || counter == 2'd1)
                 SDA = 1'b0;
               else
                 SDA = 1'b1;

               if (counter == 2'd2)
                 begin
                    ack  = 1'b1;
                    next = IDLE;
                 end
            end
        endcase
     end

   /* SCL generator */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       SCL <= 1'b1;
     else
       if (en)
         case (state)
           IDLE, STOP:
             SCL <= 1'b1;

           default
             if (counter == 2'd3 || counter == 2'd2)
               SCL <= 1'b0;
             else
               SCL <= 1'b1;
         endcase
endmodule

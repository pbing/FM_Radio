/* I²C Controller (write only) */

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

   localparam nbits = 1 + 3 * (8 + 1) + 1; // start bit + 3 * (8 bit data + 1 bit ack) + stop bit

   logic [1:0]                   phase;          // bit phase 
   logic                         phase2, phase3; // bit phase 2 and 3
   logic [$clog2(nbits) - 1 : 0] bit_counter;    // bit counter
   logic [nbits - 1 : 0]         shift;          // shift register
   logic                         load;           // load shift register

   enum int unsigned {IDLE, START, SHIFT, STOP} state, next; // FSM

   /* shift register */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       shift <= '1;
     else
       if (en)
         if (load)
           shift <= {1'b0,     // start bit
                     addr,     // addr
                     1'b0,     // R/nW = write
                     1'b1,     // ack
                     wdata[1], // 1st data byte
                     1'b1,     // ack
                     wdata[0], // 2nd data byte
                     1'b1,     // ack
                     1'b0};    // stop bit
         else
           if (state != IDLE && phase3)
             shift <= {shift[$left(shift) - 1 : 0], 1'b1};

   /* SDA is a registered output in order to avoid hazards which could
    * be possible START/STOP events when SCL is 1'b1.
    */
   assign SDA = shift[$left(shift)];

   /* bit phase */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       phase <= 2'd0;
     else
       if (en)
         if (state == IDLE)
           phase <= 2'd0;
         else
           phase <= phase + 2'd1;

   always_comb
     begin
        phase2 = (phase == 2'd2);
        phase3 = (phase == 2'd3);
     end

   /* bit counter */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       bit_counter <= 0;
     else
       if (load)
         bit_counter <= 0;
       else
         if (en && phase3)
           bit_counter <= bit_counter + 1;

   /* FSM */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       state <= IDLE;
     else
       if (en)
         state <= next;

   always_comb
     begin
        load = 1'b0;
        ack  = 1'b0;
        next = state;

        case (state)
          IDLE:
            if (req)
              next = START;
            else
              next = IDLE;

          START:
            if (phase3)
              begin
                 load = 1'b1;
                 next = SHIFT;
              end

          SHIFT:
            if (bit_counter == nbits - 2 && phase3)
              next = STOP;

          STOP:
            if (phase3)
              begin
                 ack  = 1'b1;
                 next = IDLE;
              end
        endcase
     end

   /* SCL generator
    * It is a registered output in order to avoid hazards.
    */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       SCL <= 1'b1;
     else
       if (en)
         case (state)
           IDLE, START, STOP:
             SCL <= 1'b1;

           default
             if (phase2 || phase3)
               SCL <= 1'b0;
             else
               SCL <= 1'b1;
         endcase
endmodule

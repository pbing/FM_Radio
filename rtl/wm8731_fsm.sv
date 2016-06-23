/* WM8731 FSM controller */

module wm8731_fsm
  (input  wire             reset,     // reset
   input  wire             clk,       // clock
   input  wire             en,        // clock enable
   output wire  [6:0]      addr,      // address
   output logic [1:0][7:0] wdata,     // write data
   output logic            req,       // request
   input  wire             ack );     // acknowledge

   const bit wm8731_csb = 1'b0; // tied to zero on DS1 board

   const bit [15:0] lut[9] = '{{7'd15, 9'b000000000},         // Reset
                               {7'd2,  9'b0_0_1111001},       // Left Headphone Out
                               {7'd3,  9'b0_0_1111001},       // Right Headphone Out
                               {7'd4,  9'b0_00_0_1_0_0_1_0},  // Analogue Audio Path Control
                               {7'd5,  9'b0000_0_0_01_0},     // Digital Audio Path Control
                               {7'd6,  9'b0_0_1_1_0_0_1_1_1}, // Power Down Control
                               {7'd7,  9'b0_0_0_0_0_00_11},   // Digital Audio Interface Format
                               {7'd8,  9'b0_0_0_0110_0_1},    // Sampling Control
                               {7'd9,  9'b00000000_1}};       // Active Control

   enum int unsigned {RUN[9], WAIT[9], STOP} state, next;

   assign addr = {6'b001101, wm8731_csb};

   /* FSM */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       state <= RUN0;
     else
       if (en)
         state <= next;

   always_comb
     begin
        wdata = 'x;
        req   = 1'b0;
        next  = state;

        case (state)
          RUN0:
            begin
               wdata = lut[0];
               req   = 1'b1;
               next  = WAIT0;
            end

          WAIT0:
            begin
               wdata = lut[0];

               if (ack)
                 next = RUN1;
            end

          RUN1:
            begin
               wdata = lut[1];
               req   = 1'b1;
               next  = WAIT1;
            end

          WAIT1:
            begin
               wdata = lut[1];

               if (ack)
                 next = RUN2;
            end          

          RUN2:
            begin
               wdata = lut[2];
               req   = 1'b1;
               next  = WAIT2;
            end

          WAIT2:
            begin
               wdata = lut[2];

               if (ack)
                 next = RUN3;
            end
          
          RUN3:
            begin
               wdata = lut[3];
               req   = 1'b1;
               next  = WAIT3;
            end

          WAIT3:
            begin
               wdata = lut[3];
               if (ack)
                 next = RUN4;
            end
          
          RUN4:
            begin
               wdata = lut[4];
               req   = 1'b1;
               next  = WAIT4;
            end

          WAIT4:
            begin
               wdata = lut[4];
               
               if (ack)
                 next = RUN5;
            end

          RUN5:
            begin
               wdata = lut[5];
               req   = 1'b1;
               next  = WAIT5;
            end

          WAIT5:
            begin
               wdata = lut[5];

               if (ack)
                 next = RUN6;
            end

          RUN6:
            begin
               wdata = lut[6];
               req   = 1'b1;
               next  = WAIT6;
            end

          WAIT6:
            begin
               wdata = lut[6];
               
               if (ack)
                 next = RUN7;
            end

          RUN7:
            begin
               wdata = lut[7];
               req   = 1'b1;
               next  = WAIT7;
            end

          WAIT7:
            begin
               wdata = lut[7];

               if (ack)
                 next = RUN8;
            end

          RUN8:
            begin
               wdata = lut[8];
               req   = 1'b1;
               next  = WAIT8;
            end

          WAIT8:
            begin
               wdata = lut[8];

               if (ack)
                 next = STOP;
            end

          STOP: ;
        endcase            
     end
endmodule

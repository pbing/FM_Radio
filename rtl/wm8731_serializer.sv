/* Serializer for WM8731 */

module wm8731_serializer
  (input  wire         reset,     // reset
   input  wire         clk,       // 240 MHz clock
   input  wire         en48m,     // 48 MHz clock enable
   input  wire         en32k,
   input  wire  [15:0] audio_dat, // audio data
   output logic        dac_lr_ck, // DAC L/R clock
   output wire         dac_dat,   // DAC data
   output logic        bclk,      //  2 MHz BCLK
   output logic        mclk);     // 12 MHz MCLK

   logic                en_bclk2, en_bclk;
   logic [2*16 - 1 : 0] dac_shift;

   /* MCLK generator */
   always_ff @(posedge clk or posedge reset)
     begin:mclk_gen
        logic [1:0] counter;

        if (reset)
          begin
             counter <= 2'd0;
             mclk    <= 1'b0;
          end
        else
          if (en48m)
            begin
               if (counter[0])
                 mclk <= ~mclk;

               counter <= counter + 2'd1;
            end
     end:mclk_gen

   /* BCLK generator */
   always_ff @(posedge clk or posedge reset)
     begin:en_bclk2_gen
        logic [3:0] counter;

        if (reset)
          counter  <= 4'd0;
        else
          if (en32k)
            counter  <= 4'd0;
          else
            if (en48m)
              if (counter == 4'd11)
                counter <= 4'd0;
              else
                counter <= counter + 4'd1;
     end:en_bclk2_gen

   always_comb en_bclk2 = (en_bclk2_gen.counter == 4'd11) && en48m;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       bclk <= 1'b0;
     else
       if (en32k)
         bclk <= 1'b0;
       else if (en_bclk2)
         bclk <= ~bclk;

   always_comb en_bclk = en_bclk2 & bclk;

   /* L/R clock generator */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       dac_lr_ck <= 1'b0;
     else
       if (en32k)
         dac_lr_ck <= 1'b1;
       else if(en_bclk)
         dac_lr_ck <= 1'b0;

   /* DAC shift register */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       dac_shift <= '0;
     else
       if (en32k)
         dac_shift <= {audio_dat, audio_dat};
       else if (en_bclk)
         dac_shift <= {dac_shift[$left(dac_shift) - 1:0], 1'b0};

   assign dac_dat = dac_shift[$left(dac_shift)];
endmodule

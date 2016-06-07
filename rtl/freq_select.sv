/* Frequency selector */

module freq_select
  #(parameter width_dds)
   (input  wire  [9:0]               SW,       // toggle switch
    output logic [6:0]               HEX[3:0], // seven segment digits
    output logic [width_dds - 1 : 0] K);       // DDS phase reload constant

   always_comb
     case(SW)
       10'd1:
         begin
            K   = f_to_k(87.7e6);    // SWR1
            HEX = hex_display(0877);
         end
       10'd1:
         begin
            K   = f_to_k(89.3e6);    // hr3
            HEX = hex_display(0893);
         end
       10'd2:
         begin
            K   = f_to_k(93.7e6);    // SWR3
            HEX = hex_display(0937);
         end
       10'd4:
         begin
            K   = f_to_k(98.1e6);    // RPR1
            HEX = hex_display(0981);
         end
       10'd8:
         begin
            K   = f_to_k(107.9e6);   // Rockland Radio
            HEX = hex_display(1079);
         end
       default
         10'd1:
           begin
              K   = f_to_k(100.0e6); // generic
              HEX = hex_display(1000);
           end
     endcase

   function [width_dds - 1 : 0] f_to_k(input real f);
      2**32 * f / 240.0e6;
   endfunction

   function void hex_display(input int n);
      const bit [6:0] d[16] = {'h3f, 'h06, 'h5b, 'h4f, 'h66, 'h6d, 'h7d, 'h07,  // 0 1 2 3 4 5 6 7
                               'h7f, 'h6f, 'h77, 'h7c, 'h39, 'h5e, 'h79, 'h71}; // 8 9 A b C d E F

      for (int i = 0; i < 16; ++i)
        HEX[i] = d[(n >> (4 * i))  & '4hf];
   endfunction
endmodule

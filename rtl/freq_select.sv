/* Frequency selector */

module freq_select
  #(parameter width_dds)
   (input  wire  [9:0]               SW,  // toggle switch
    output logic [3:0][6:0]          HEX, // seven segment digits
    output logic [width_dds - 1 : 0] K);  // DDS phase reload constant

   always_comb
     case(SW)
       10'h1:
         begin
            K = 2**32 * 87.7e6 / 240.0e6;  // SWR1
            hex_display('h0877);
         end
       10'h1:
         begin
            K = 2**32 * 89.3e6 / 240.0e6;  // hr3
            hex_display('h0893);
         end
       10'h2:
         begin
            K = 2**32 * 93.7e6 / 240.0e6;  // SWR3
            hex_display('h0937);
         end
       10'h4:
         begin
            K = 2**32 * 98.1e6 / 240.0e6;  // RPR1
            hex_display('h0981);
         end
       10'h8:
         begin
            K = 2**32 * 107.9e6 / 240.0e6; // Rockland Radio
            hex_display('h1079);
         end
       default
         begin
            K = 2**32 * 100.0e6 / 240.0e6; // generic 100.0 MHz
            hex_display('h1000);
         end
     endcase

   function void hex_display(input int n);
      const bit [6:0] d[16] = '{'h3f, 'h06, 'h5b, 'h4f, 'h66, 'h6d, 'h7d, 'h07,  // 0 1 2 3 4 5 6 7
                                'h7f, 'h6f, 'h77, 'h7c, 'h39, 'h5e, 'h79, 'h71}; // 8 9 A b C d E F

      for (int i = 0; i < 4; ++i)
        HEX[i] = ~d[(n >> (4 * i)) & 4'hf];
   endfunction
endmodule

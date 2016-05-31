/* 1-bit I/Q modulator
 *
 * ω1: broadcast carrier at input 'adc'
 * ω2: local oscillator from DDS
 *
 * Tuned, when ω1 = ω2.
 *
 * I = cos(ω1∙t + θ)∙cos(ω2)
 * Q = cos(ω1∙t + θ)∙(-sin(ω2))
 */

module iq_modulator
  (input  wire               clk,
   input  wire               adc,
   input  wire  signed [1:0] phase,
   output logic signed [1:0] I, Q);

   /* I =  cos(phase) * ADC
    * Q = -sin(phase) * ADC
    */
   always_ff @(posedge clk)
     case (phase)
       2'b00:
         begin
            I <=  to_signed(adc);
            Q <= -to_signed(adc);
         end

       2'b01:
         begin
            I <= -to_signed(adc);
            Q <= -to_signed(adc);
         end

       2'b10:
         begin
            I <= -to_signed(adc);
            Q <=  to_signed(adc);
         end

       2'b11:
         begin
            I <= to_signed(adc);
            Q <= to_signed(adc);
         end
     endcase

   function logic signed [1:0] to_signed(input x);
      return 2 * x - 1;
   endfunction
endmodule

.\" .nr PS 12
.EQ
delim $$
.EN
.NH
Design parameters
.LP
.TS
center allbox tab(;);
cb cb cb cb cb cb
l c c c c l.
parameter   ; min. ; typ. ; max.  ; unit ; comment
$f sub c$   ; 87.5 ;      ; 108.5 ; MHz  ; broadcast carrier frequency
$ Delta f$  ;      ;      ; 75    ; kHz  ; frequency deviation
$B$         ;      ; 210  ;       ; kHz  ; base-band bandwidth
$tau$       ;      ; 50   ;       ; µs   ; de-emphasis time constant (Europe)
$f sub m$   ; 0.03 ;      ; 15    ; kHz  ; modulation frequency
$f sub s$   ;      ; 240  ;       ; MHz  ; sampling frequency
$f sub b$   ;      ; 960  ;       ; kHz  ; base-band clock rate
$f sub DAC$ ; 32   ;      ;       ; kHz  ; output clock rate for DAC
$f sub MCLK$;      ;      ; 18.5  ; MHz  ; WM8731 master clock frequency
$f sub BCLK$;      ;      ; 20    ; MHz  ; WM8731 bit clock frequency
.TE
.LP
The following constraints have to be fullfilled.
.EQ
f sub s mark > 2 cdot f sub c
.EN
.EQ
B lineup > 2 cdot ( Delta f + 2 cdot f sub m ) ~~~~ roman "Carson's bandwidth rule"
.EN
.EQ
f sub b lineup > B
.EN
.EQ
f sub DAC lineup > 2 cdot f sub m
.EN
.EQ
f sub BCLK lineup >= 2 cdot 16 cdot f sub DAC ~~~~ roman "with 16\ bit audio data"
.EN
.NH
Downsampling to I/Q base-band
.LP
The I/Q modulator works with 1-bit signals.
The upper two bits of the DDS's phase accumulator represent the
quadrant.
.LP
The multiply operation is performed by a simple XOR logic.
As a result, the I/Q base-band signal are triangular waves instead of
pure sines/cosines which will lead to harmonic distortions of
$4 cdot Delta f$.
.NH
Base-band filter
.LP
The base-band filter is compromised of two third order cascaded
integrator-comb (CIC) filters.
After the first filter the data rate is 48\ MHz, after the second
filter 960\ kHz.
The first zero is $f sub c / R$ where $R$ is the decimation
factor of the CIC filter.
.LP
The base-band bandwith should be larger than $B$.
For optimal channel separation it should be less than 400\ kHz.
.NH
Frequency discriminator
.LP
The I/Q base-band signal is connected to the CORDIC module which will
calculate the phase.
.EQ
theta = arc tan Q over I
.EN
After differentiation of the phase the signal is restored.
.EQ
omega sub m = { d theta } over { d t }
.EN
.NH
Downsampling to audio sample rate
.LP
A third order CIC decimator converts from base-band sample rate to
audio sample rate.
This effectively removes any frequencies above 15\ kHz, e.g. MPX
and RDS signals.
Because no sinc-correction has been made yet, the transfer function
will drop at higher audio frequencies.
.NH
De-emphasis
.NH 2
De-emphasis with IIR filter
.LP
A de-emphasis filter with the transfer function
.EQ
H(s) = 1 over {1 + tau cdot s}
.EN
corrects the pre-emphased audio signal of the broadcast station.
.LP
Impulse invariance method converts $H(s)$ to $H(z)$.
.EQ
H(z) mark = {b sub 0} over {1 + a sub 1 cdot z sup {-1}}
.EN
.EQ
a sub 1 lineup = - e sup {- ^ {1 over {tau cdot f sub DAC}}}
.EN
.EQ
b sub 0 lineup = 1 + a sub 1
.EN
.NH 2
De-emphasis with build-in filter of the WM8731
.LP
The DAC filter of the WM8731 can apply digital de-emphasis.
The analogue transfer function is
.EQ
H(s) = {1 + tau sub 2 cdot s} over {1 + tau sub 1 cdot s}
.EN
with $tau sub 1 = 50~roman µs$ and $tau sub 2 = 15~roman µs$.
The zero at 10.6\ kHz partly compensates the \fIsinc\fP drop caused by
the CIC decimation filter.
.NH
Audio interface
.LP
The Altera\ DE1 board contains the audio CODEC WM8731 from Wolfson
Microelectronics.
.LP
After reset the CODEC will be initialized via I²C two-wire interface
to 12\ MHz MCLK, 32\ kHz sampling rate, 16\ bit audio data length,
DSP/PCM mode\ B and enabled de-emphasis.
.TS
center allbox tab(;);
cb cb cb cb
c  l  c l.
register ; name ; data ; comment
R0  ; Left Line In                   ; 010010111 ; default
R1  ; Right Line In                  ; 010010111 ; default
R2  ; Left Headphone Out             ; 001111001 ; LHPVOL = 0\ dB
R3  ; Right Headphone Out            ; 001111001 ; RHPVOL = 0\ dB
R4  ; Analogue Audio Path Control    ; 000010010 ; DACSEL, MUTEMIC
R5  ; Digital Audio Path Control     ; 000000010 ; DEEMP = 32\ kHz
R6  ; Power Down Control             ; 001100111 ; POWEROFF = 0, OUTPD = 0, DACPD = 0
R7  ; Digital Audio Interface Format ; 000000011 ; IWL = 16\ bits, FORMAT = DSP\ mode
R8  ; Sampling Control               ; 000011001 ; 32 kHz, USB mode
R9  ; Active Control                 ; 000000001 ; ACTIVE
R15 ; Reset                          ; \(em      ; reset, when written with zeros
.TE
Serial audio data is transferred with the signals BCLK, DACDAT and
DACLRC.
.NH
Antenna connection
.LP
For the antenna input an I/O input buffer without hysteresis is needed.
A differential input of type LVECL at EXT_CLOCK/SW[2] was choosen.
.LP
The antenna (a wire of 1\ m length) was directly connected to EXT_CLOCK.
No LC-circuit for tuning was needed.
.NH
Results
.LP
Three local broadcast stations could be received.
The audio signal was of reasonable quality.
If there were harmonic distorsions they were not very audible.
.\" Local Variables:
.\" coding: iso-latin-1
.\" End:

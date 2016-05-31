.\" -*- coding: utf-8 -*-
.\" .nr PS 12
.EQ
delim $$
.EN
.TS
center allbox tab(;);
cb cb cb cb cb cb
l c c c c l.
parameter   ; min. ; typ. ; max.  ; unit ; comment
$f sub c$   ; 87.5 ;      ; 108.5 ; MHz  ; broadcast carrier frequency
$ Delta f$  ;      ;      ; 75    ; kHz  ; frequency deviation
$B$         ;      ; 210  ;       ; kHz  ; channel bandwidth
$f sub m$ ; 0.03 ;      ; 15    ; kHz  ; modulation frequency
$f sub s$   ;      ; 240  ;       ; MHz  ; sampling frequency
$f sub b$   ;      ; 1    ;       ; MHz  ; base band clock rate    
$f sub DAC$ ; 32   ;      ; 48    ; kHz  ; output clock rate for DAC
$tau$       ;      ; 50   ;       ; µs   ; de-emphasis time constant (Europe)
.TE
.LP
The following constraints have to be fullfilled.
.EQ
f sub s mark > 2 cdot f sub c
.EN
.EQ
f sub s lineup > 2 cdot pi cdot f sub m
.EN
.EQ
f sub DAC lineup > 2 cdot f sub m
.EN
.EQ
B lineup > 2 ( Delta f + 2 cdot f sub m ) ~~~~roman "Carson's bandwidth rule"
.EN
.EQ
f sub b lineup > B
.EN




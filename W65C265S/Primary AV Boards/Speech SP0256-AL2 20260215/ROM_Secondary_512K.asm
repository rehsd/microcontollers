;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
;   phsyically $00:0000 to $07:FFFF in the secondary flash chip, but mapped into CPU address space at $40:0000 to $47:FFFF

MyCode.65816.asm
.org $000000
.fill $80000, $FF   ; fill unused space with 0xFF - much faster flash programming


.org $000000
    .byte 		"rehsd!"


; rom stuff goes here...

.org $07FFFA
    .byte 		"rehsd!"
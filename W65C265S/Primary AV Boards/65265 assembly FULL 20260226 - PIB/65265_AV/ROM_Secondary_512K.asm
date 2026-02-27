;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
;   phsyically $00:0000 to $07:FFFF in the secondary flash chip, but mapped into CPU address space at $40:0000 to $47:FFFF

.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

MyCode.65816.asm
.org $000000
.fill $80000, $FF   ; fill unused space with 0xFF - much faster flash programming


.org $000000
    .byte 		"rehsd!"

    ; OS call helper
        CALL_OS_ADDR = $00F200
        sysptr = $001000   ; address on OS RAM

    ; SysCallTable:  ; table of OS routine addresses (24-bit)
        SYS_ILI_PrintChar = 0
        ; room more more


.org $001000    ; really $001000 + $40:0000 = $40:1000 in app address space (secondary flash)



.org $07FFFA
    .byte 		"rehsd!"
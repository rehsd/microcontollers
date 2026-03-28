; Shell (C)
;	* Code loaded from secondary ROM into $01:0000 and runs from there
;	* Extended RAM of $01:0000 to $02:FFFF available for C code and variables (128K)
;	* Bank 0: Variables in $00:4000 to $00:6FFF (12K)									* $00:4000 to $00:6FFF (DP is first 256 bytes of this space)
;	* 	Direct page is first 256 bytes of Bank 0 memory
;	* 	Stack within this space (6K)

(define memories
'(
(memory APP_ZP (address (#x04000 . #x040FF)) (type ANY))
(memory APP_RAM_DATA (address (#x04100 . #x06FFF)) (type ANY))
(memory APP_RAM_CODE (address (#x10000 . #x2FFFF)) (type ANY))
(memory CS4B_FLASH (address (#x8000 . #xFFFF)) (type ANY))
)
)

(define sections
  '(
    ;; 1. Lock the 4-byte jump to the specific memory slot
    (section fixed_jmp (memory APP_FIXED_ENTRY))

    ;; 2. Ensure the compiler's entry/appentry sections stay in main RAM
    (section entry (memory APP_RAM_CODE))
    
    ;; 3. Standard catch-all rules
    (section farcode (memory APP_RAM_CODE))
    (section code (memory APP_RAM_CODE))

    ;; --- ADD THESE TO FORCE BANK 1 GENERATION ---
    (section cdata (memory APP_RAM_DATA))
    (section cnear (memory APP_RAM_DATA))
    ;; --------------------------------------------

    (section zdata (memory APP_ZP))
    (section data (memory APP_RAM_DATA))
    (section bss (memory APP_RAM_DATA))
    (section stack (memory APP_RAM_DATA))
    (section far_data (memory APP_RAM_DATA))
  )
)
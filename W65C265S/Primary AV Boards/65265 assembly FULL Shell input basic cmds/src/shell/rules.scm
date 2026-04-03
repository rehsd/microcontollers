; Shell (C)
;	* Code loaded from secondary ROM into $01:0000 and runs from there
;	* Extended RAM of $01:0000 to $02:FFFF available for C code and variables (128K)
;	* Bank 0: Variables in $00:2000 to $00:6FFF (20K)	
; * Stack is 4K within bank 0 space
;	* 	Direct page is first 256 bytes of Bank 0 memory

(define memories
'(
(memory APP_ZP (address (#x02000 . #x020FF)) (type DATA))
(memory APP_RAM_DATA (address (#x02100 . #x05FFF)) (type ANY))
(memory APP_RAM_CODE (address (#x10000 . #x2FFFF)) (type ANY))
(memory CS4B_FLASH (address (#x8000 . #xFFFF)) (type ROM))
)
)

(define sections
  '(
    ;; --- 1. ENTRY POINT ---
    ;; Force the compiler's entry/appentry into the 128K Extended RAM
    (section entry (memory APP_RAM_CODE))

    ;; --- 2. CODE (24-bit / Bank 1+ / Bank 3+) ---
    ;; All executable code lives in the large extended memory block
    (section code (memory APP_RAM_CODE))
    (section farcode (memory APP_RAM_CODE))

    ;; --- 3. FAR DATA (24-bit / Bank 1+ / Bank 3+) ---
    ;; Large buffers, arrays, and __far variables go here to save Bank 0
    (section far_data (memory APP_RAM_CODE))
    (section cdata (memory APP_RAM_CODE))
    (section cnear (memory APP_RAM_CODE))

    ;; --- 4. NEAR DATA (Bank 0 / 16-bit Absolute) ---
    ;; Small globals and statics used frequently by the C compiler
    (section data (memory APP_RAM_DATA))
    (section bss (memory APP_RAM_DATA))

    ;; --- 5. ZERO PAGE (Bank 0 / 8-bit Direct Page) ---
    ;; Critical for the C compiler's "virtual registers" and fast access
    (section zdata (memory APP_ZP))

    ;; --- 6. STACK (Bank 0 / 16-bit) ---
    ;; Must be in Bank 0 for the 65816 hardware
    (section stack (memory APP_RAM_DATA))
  )
)
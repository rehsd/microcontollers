; C Applications (e.g., gfxTest)
;	* Code loaded from SD Card into $03:0000 and runs from there
;	* Extended RAM of $03:0000 to $04:FFFF available for C code and variables (128K)
;	* Bank 0: Variables in $00:1800 to $00:3FFF (10K)
;	* 	Direct page is first 256 bytes of Bank 0 memory
; 	*   Stack wthin this space (6K)

(define memories
'(
(memory APP_ZP (address (#x01800 . #x018FF)) (type ANY))
(memory APP_RAM_DATA (address (#x01900 . #x03FFF)) (type ANY))
(memory APP_RAM_CODE (address (#x30000 . #x4FFFF)) (type ANY))
(memory CS4B_FLASH (address (#x8000 . #xFFFF)) (type ANY))
)
)

(define sections
  '(
    ;; 2. Ensure the compiler's entry/appentry sections stay in main RAM
    (section entry (memory APP_RAM_CODE))
    
    ;; 3. Standard catch-all rules
    (section farcode (memory APP_RAM_CODE))
    (section code (memory APP_RAM_CODE))

    ;; --- ADD THESE TO FORCE BANK 1 GENERATION ---
    (section cdata (memory APP_RAM_CODE))
    (section cnear (memory APP_RAM_CODE))
    ;; --------------------------------------------

    (section zdata (memory APP_ZP))
    (section data (memory APP_RAM_DATA))
    (section bss (memory APP_RAM_DATA))
    (section stack (memory APP_RAM_DATA))
  )
)
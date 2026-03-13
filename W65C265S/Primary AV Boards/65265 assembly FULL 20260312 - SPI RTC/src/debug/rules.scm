(define memories
'(
(memory APP_FIXED_ENTRY (address (#x04000 . #x04003)) (type ANY))
(memory APP_ZP (address (#x02000 . #x02FFF)) (type ANY))
(memory APP_RAM_DATA (address (#x04004 . #x05FFF)) (type ANY))
(memory APP_RAM_CODE (address (#x60000 . #x6FFFF)) (type ANY))
(memory CS7B_GAL_SRAM (address (#xF0000 . #xF07FF)) (type ANY))
(memory CS7B_VGA_VRAM (address (#xEA000 . #xEBFFF)) (type ANY))
(memory CS6B_FLASH (address (#x40000 . #x47FFF)) (type ANY))
(memory CS5B_SRAM (address (#x10000 . #x7FFFF)) (type ANY))
(memory CS4B_FLASH (address (#x8000 . #xFFFF)) (type ANY))
(memory CS3B_SRAM (address (#x0000 . #x7FFF)) (type ANY))
(memory CS2B_ONCHIP_ROM (address (#xE000 . #xFEFF)) (type ANY))
(memory CS2B_ONCHIP_RAM (address (#x0000 . #x01FF)) (type ANY))
(memory CS1B_EXT_CS1 (address (#xDFC0 . #xDFFF)) (type ANY))
(memory CS0B_EXT_CS0 (address (#xDF00 . #xDF1F)) (type ANY))
)
)

(define sections
  '(
    ;; 1. Lock the 4-byte jump to the specific memory slot
    (section fixed_jmp (memory APP_FIXED_ENTRY))

    ;; 2. Ensure the compiler's entry/appentry sections stay in main RAM
    (section entry (memory APP_RAM_CODE))
    //(section appentry (memory APP_RAM_CODE))
    
    ;; 3. Standard catch-all rules
    (section farcode (memory APP_RAM_CODE))
    (section code (memory APP_RAM_CODE))
    (section zdata (memory APP_ZP))
    (section data (memory APP_RAM_DATA))
    (section bss (memory APP_RAM_DATA))
    (section stack (memory APP_RAM_DATA))
  )
)
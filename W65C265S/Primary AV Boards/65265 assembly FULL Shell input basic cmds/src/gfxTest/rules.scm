;; gfxTest App - Bank 0 Entry Configuration
;; Targets Bank 0 ($1800-$1FFF) and Bank 3 ($30000-$3FFFF)

(define memories
  '(
    ;; 1. Direct Page / Zero Page (256 bytes)
    (memory DirectPage (address (#x1800 . #x18FF))
            (section registers ztiny zfar znear))

    ;; 2. Bank 0 Variables (NOBITS)
    (memory NearRAM_Vars (address (#x1900 . #x197F))
            (section zdata data bss))

    ;; 3. Bank 0 Startup & Library Code (BITS)
    ;; 'entry' is now here so __program_start is a 16-bit address.
    (memory NearRAM_Bits (address (#x1980 . #x19FF))
            (section entry code cdata switch))

    ;; 4. Dedicated Stack Block
    (memory StackRAM (address (#x1A00 . #x1FFF))
            (section stack))

    ;; 5. Extended RAM (Bank 3)
    ;; Application logic and far-constants live here.
    (memory AppRAM (address (#x30000 . #x3FFFF))
            (section farcode far_data cfar chuge inear data_init_table))

    ;; 6. Flash ROM
    (memory Flash (address (#x8000 . #xFFEF))
            (type ROM))

    ;; 7. Vectors
    (memory Vector (address (#xFFF0 . #xFFFF))
            (section (reset #xFFFC)))

    ;; Block definitions
    (block stack (size #x0600))
    
    ;; --- Internal Linker Symbols ---
    (base-address _DirectPageStart DirectPage 0)
    (base-address _NearBaseAddress DirectPage -6144)
   )
)
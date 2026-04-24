;; gfxTest App - Full Fixed Nesting
;; Targets Bank 0 ($1800-$1FFF) and Bank 3 ($30000-$3FFFF)
;; much of this is only to get compilation done
;; jumping straight to AppEntry, and skipping C runtime init functions
;; app will use DP, stack, etc. of Shell
;; generally, 00:1800 to 00:1FFF is available for the app,
;; along with 03:0000 to 04:FFFF

(define memories
  '(
    ;; 5. Application Entry Point (STRICTLY at 0x30000)
    (memory AppEntry (address (#x30000 . #x300FF))
            (section appStart))

    ;; 1. Direct Page / Zero Page (256 bytes)
    (memory DirectPage (address (#x1800 . #x18FF))
            (section registers ztiny zfar znear))

    ;; 2. Bank 0 Variables (NOBITS)
    (memory NearRAM_Vars (address (#x1900 . #x197F))
            (section zdata data bss))

    ;; 3. Bank 0 Startup & Library Landing Pad (BITS)
    (memory NearRAM_Bits (address (#x1980 . #x19FF))
            (section entry code cdata switch))

    ;; 4. Dedicated Stack Block (Bank 0)
    (memory StackRAM (address (#x1A00 . #x1FFF))
            (section stack))



    ;; 6. Extended RAM (Rest of Bank 3)
    (memory AppRAM (address (#x30100 . #x3FFFF))
            (section text farcode reset rodata cfar chuge inear far_data data_init_table))

    ;; 7. Flash ROM (Optional)
    (memory Flash (address (#x8000 . #xFFEF))
            (type ROM))

    ;; 8. Vectors
    (memory Vector (address (#xFFF0 . #xFFFF))
            (section (reset #xFFFC)))

    ;; --- NESTED DIRECTIVES (Must be inside define memories) ---
    (block stack (size #x0600))
    
    (base-address _DirectPageStart DirectPage 0)
    (base-address _NearBaseAddress DirectPage -6144)
   )
)
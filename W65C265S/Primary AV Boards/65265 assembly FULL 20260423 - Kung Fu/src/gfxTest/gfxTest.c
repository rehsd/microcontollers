#include "../include/calypsi_intellisense_fix.h"
#include <calypsi/intrinsics65816.h>

#define SYSCALL_PARAMS ((volatile unsigned char*)0x0F00)

void main(void);

__attribute__((section("appStart")))    // this will be at $03:0000
void app_init(void){
    main();
    __asm(" rtl");
}

void main(void) {
    const char *p = "Hello from gfxTest!";
    while (*p) {
        // Place the character value at address 0x0F00
        SYSCALL_PARAMS[0] = (unsigned char)(*p);
        
        // Execute the COP handler
        __asm(" cop #1");
        
        p++;
    }
   
    __asm(" cop #3\n");
    __asm(" cop #4\n");
    
}
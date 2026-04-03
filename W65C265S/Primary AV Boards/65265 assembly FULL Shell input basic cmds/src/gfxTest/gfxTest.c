#include "../include/calypsi_intellisense_fix.h"
#include <calypsi/intrinsics65816.h>

//#define SYSCALL_PARAMS ((volatile unsigned char*)0x0F00)

// This now defaults to Bank 03 'AppRAM' automatically
// static const char msg[] = "Large Model App Loaded!\r\n";


void main(void) {
    // const char *p = msg; // 24-bit pointer by default

    // while (*p) {
    //     unsigned long addr = (unsigned long)p;
        
    //     // Pass 24-bit address to the Shell's COP handler
    //     SYSCALL_PARAMS[0] = (unsigned char)(addr & 0xFF);
    //     SYSCALL_PARAMS[1] = (unsigned char)((addr >> 8) & 0xFF);
    //     SYSCALL_PARAMS[2] = (unsigned char)((addr >> 16) & 0xFF);
        
    //     __asm(" cop #1");
        
    //     p++;
    // }
   
    // __asm(" cop #3\n");
    // __asm(" cop #4\n");
    
    __asm(" rtl");
}
#include "../include/calypsi_intellisense_fix.h"

#define SYSCALL_PARAMS (*(volatile unsigned char*)0x0F00)

static const char msg[] = " -- from C! ";
static unsigned char test_char;

static inline void os_print_char(char c)
{
    SYSCALL_PARAMS = c;   // store to $0F00 in C
    //__asm(" .byte 0x02, 0x01\n");   // COP #1
    __asm(" cop #1\n");   // COP #1
}

static inline void os_newline(void)
{
    //__asm(" .byte 0x02, 0x02\n");   // COP #2
    __asm(" cop #2\n");   // COP #2
}

static inline void os_debug_mark(void)
{
    //__asm(" .byte 0x02, 0x02\n");   // COP #2
    __asm(" cop #3\n");   // COP #3
}

static inline void os_debug_mark2(void)
{
    //__asm(" .byte 0x02, 0x02\n");   // COP #2
    __asm(" cop #4\n");   // COP #3
}

static inline void os_c_return(void)
{
    //to do: any cleanup needed before returning to '265?
    //__asm(" .byte 0x02, 0x05\n");   // COP #5
    __asm(" cop #5\n");   // COP #5
}

static inline void os_puts(const char* s)
{
    while (*s) {
        os_print_char(*s++);
    }
}

void main(void) {
    os_debug_mark();

    os_newline();
    os_print_char(' ');

    os_puts("*Hello, world, from C!");

    os_debug_mark2();

    //return;
    //__asm(" rtl\n");
    os_c_return();
}
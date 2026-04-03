#include "os.h"



void os_draw_rectangle(unsigned short x, unsigned short y, unsigned short width, 
                                    unsigned short height, unsigned short color, unsigned char filled)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  width_lo, width_hi, height_lo, height_hi, 
    //                                  color_lo, color_hi, filled
    // COP_CMD_DRAW_RECTANGLE      .equ  $06

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(width & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(width >> 8);
    SYSCALL_PARAMS.param6  = (unsigned char)(height & 0xFF);
    SYSCALL_PARAMS.param7  = (unsigned char)(height >> 8);
    SYSCALL_PARAMS.param8  = (unsigned char)(color & 0xFF);
    SYSCALL_PARAMS.param9  = (unsigned char)(color >> 8);
    SYSCALL_PARAMS.param10 = filled;

    __asm(" cop #6\n");   // COP #6
}

void os_print_char(char c)
{
    SYSCALL_PARAMS_START = c;   // store to $0F00 in C
    __asm(" cop #1\n");   // COP #1
}

void os_newline(void)
{
    __asm(" cop #2\n");   // COP #2
}

void os_newline_with_prompt(void)
{
    __asm(" cop #2\n");   // COP #2
    os_print_char('$');
}

void os_debug_mark(void)
{
    __asm(" cop #3\n");   // COP #3
}

void os_debug_mark2(void)
{
    __asm(" cop #4\n");   // COP #3
}

void os_c_return(void)
{
    //to do: any cleanup needed before returning to '265?
    __asm(" cop #5\n");   // COP #5
}

void os_puts(const char* s)
{
    while (*s) {
        os_print_char(*s++);
    }
}

void os_clear_screen(void)
{
    __asm(" cop #0x11\n");
}

void os_print_char_serial(char c)
{
    SYSCALL_PARAMS_START = c;   // store to $0F00 in C
    __asm(" cop #0x12\n"); 
}

void os_newline_serial(void)
{
    __asm(" cop #0x13\n");
}

void os_puts_serial(const char* s)
{
    while (*s) {
        os_print_char_serial(*s++);
    }
}

unsigned char os_kbd_get_char()
{
    __asm(" cop #0x10\n");
    return SYSCALL_PARAMS_RESULT;
}


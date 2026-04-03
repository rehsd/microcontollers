#ifndef OS_H
#define OS_H

#define SYSCALL_PARAMS_START (*(volatile unsigned char*)0x0F00)
#define SYSCALL_PARAMS_RESULT (*(volatile unsigned char*)0x0FFE)
#define SYSCALL_PARAMS (*(volatile syscall_params_t*)0x0F00)

typedef struct {
    unsigned char param0;
    unsigned char param1;
    unsigned char param2;
    unsigned char param3;
    unsigned char param4;
    unsigned char param5;
    unsigned char param6;
    unsigned char param7;
    unsigned char param8;
    unsigned char param9;
    unsigned char param10;
    unsigned char param11;
} syscall_params_t;


#define SYSCALL_PARAMS (*(volatile syscall_params_t*)0x0F00)

void os_draw_rectangle(unsigned short x, unsigned short y, unsigned short width, unsigned short height, unsigned short color, unsigned char filled);
void os_print_char(char c);
void os_newline(void);
void os_newline_with_prompt(void);
void os_debug_mark(void);
void os_debug_mark2(void);
void os_c_return(void);
void os_puts(const char* s);
void os_clear_screen(void);
void os_print_char_serial(char c);
void os_newline_serial(void);
void os_puts_serial(const char* s);
unsigned char os_kbd_get_char();


#endif
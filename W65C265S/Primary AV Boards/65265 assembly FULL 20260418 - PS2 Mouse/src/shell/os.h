#ifndef OS_H
#define OS_H

#define SYSCALL_PARAMS_START (*(volatile unsigned char*)0x0F00)
#define SYSCALL_PARAMS_RESULT (*(volatile unsigned char*)0x0FFE)
#define SYSCALL_PARAMS (*(volatile syscall_params_t*)0x0F00)

#define PD6 (*(volatile unsigned char*)0xDF22)
#define VIA2_PORTB (*(volatile unsigned char __far*)0xE00000L)


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

// GENERAL INPUT / OUTPUT
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
char os_kbd_wait_for_key();

// GRAPHICS 
void os_draw_rectangle(unsigned short x, unsigned short y, unsigned short width, unsigned short height, unsigned short color, unsigned char filled);
void os_draw_line(unsigned short start_x, unsigned short start_y, unsigned short end_x, unsigned short end_y, unsigned short color);
void os_draw_circle(unsigned short x, unsigned short y, unsigned short radius, unsigned short color, unsigned char filled);
void os_draw_pixel(unsigned short x, unsigned short y, unsigned short color);
void os_draw_diamond(unsigned short x, unsigned short y, unsigned short radius, unsigned short color, unsigned char filled);
void os_set_char_xy(unsigned short x, unsigned short y);
void os_set_char_color(unsigned short newColor);
void os_draw_sprite32(unsigned short x, unsigned short y, unsigned short sprite_id);
void os_draw_sprite16(unsigned short x, unsigned short y, unsigned short sprite_id);
void os_tile_backup_16(unsigned short x, unsigned short y);
void os_tile_backup_32(unsigned short x, unsigned short y);
void os_tile_restore_16(unsigned short x, unsigned short y);
void os_tile_restore_32(unsigned short x, unsigned short y);
void os_draw_sprite8(unsigned short x, unsigned short y, unsigned short sprite_id);
void os_tile_backup_8(unsigned short x, unsigned short y);
void os_tile_restore_8(unsigned short x, unsigned short y);


char mouse_read_byte_c();

int mouse_x = 160;
int mouse_y = 120;


#endif
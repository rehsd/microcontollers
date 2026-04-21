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

int nes_x = 160;
int nes_y = 120;

#define NES_LATCH 0x01 // PB0
#define NES_CLOCK 0x02 // PB1
#define NES_DATA  0x04 // PB2

// NES Controller Button Masks
#define NES_A       0x80 // %10000000
#define NES_B       0x40 // %01000000
#define NES_SELECT  0x20 // %00100000
#define NES_START   0x10 // %00010000
#define NES_UP      0x08 // %00001000
#define NES_DOWN    0x04 // %00000100
#define NES_LEFT    0x02 // %00000010
#define NES_RIGHT   0x01 // %00000001

unsigned char read_nes_gamepad_c();

void os_play_music(unsigned short music_id);
void os_play_sfx(unsigned short sfx_id);

#endif
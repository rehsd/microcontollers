#include "os.h"
#include "../include/calypsi_intellisense_fix.h"


void os_draw_rectangle(unsigned short x, unsigned short y, unsigned short width, unsigned short height, unsigned short color, unsigned char filled)
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

void os_draw_line(unsigned short start_x, unsigned short start_y, unsigned short end_x, unsigned short end_y, unsigned short color)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  width_lo, width_hi, height_lo, height_hi, 
    //                                  color_lo, color_hi

    SYSCALL_PARAMS.param0  = (unsigned char)(start_x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(start_x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(start_y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(start_y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(end_x & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(end_x >> 8);
    SYSCALL_PARAMS.param6  = (unsigned char)(end_y & 0xFF);
    SYSCALL_PARAMS.param7  = (unsigned char)(end_y >> 8);
    SYSCALL_PARAMS.param8  = (unsigned char)(color & 0xFF);
    SYSCALL_PARAMS.param9  = (unsigned char)(color >> 8);

    __asm(" cop #8\n");
}

void os_draw_circle(unsigned short x, unsigned short y, unsigned short radius, unsigned short color, unsigned char filled)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  radius_lo, radius_hi,   (height_lo, height_hi,  NOT USED)
    //                                  color_lo, color_hi, filled

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(radius & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(radius >> 8);
    // SYSCALL_PARAMS.param6  = (unsigned char)(height & 0xFF);
    // SYSCALL_PARAMS.param7  = (unsigned char)(height >> 8);
    SYSCALL_PARAMS.param8  = (unsigned char)(color & 0xFF);
    SYSCALL_PARAMS.param9  = (unsigned char)(color >> 8);
    SYSCALL_PARAMS.param10 = filled;

    __asm(" cop #7\n");
}

void os_draw_pixel(unsigned short x, unsigned short y, unsigned short color)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  color_lo, color_hi

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    // SYSCALL_PARAMS.param4  = (unsigned char)(radius & 0xFF);
    // SYSCALL_PARAMS.param5  = (unsigned char)(radius >> 8);
    // SYSCALL_PARAMS.param6  = (unsigned char)(height & 0xFF);
    // SYSCALL_PARAMS.param7  = (unsigned char)(height >> 8);
    SYSCALL_PARAMS.param8  = (unsigned char)(color & 0xFF);
    SYSCALL_PARAMS.param9  = (unsigned char)(color >> 8);
    // SYSCALL_PARAMS.param10 = filled;

    __asm(" cop #9\n");
}

void os_draw_diamond(unsigned short x, unsigned short y, unsigned short radius, unsigned short color, unsigned char filled)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  radius_lo, radius_hi,   (height_lo, height_hi,  NOT USED)
    //                                  color_lo, color_hi, filled

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(radius & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(radius >> 8);
    // SYSCALL_PARAMS.param6  = (unsigned char)(height & 0xFF);
    // SYSCALL_PARAMS.param7  = (unsigned char)(height >> 8);
    SYSCALL_PARAMS.param8  = (unsigned char)(color & 0xFF);
    SYSCALL_PARAMS.param9  = (unsigned char)(color >> 8);
    SYSCALL_PARAMS.param10 = filled;

    __asm(" cop #0x16\n");
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

char os_kbd_wait_for_key() {
    char c = 0;
    
    // Clear any stale characters in the buffer first
    while(os_kbd_get_char() != 0);

    // Block here until a key is actually pressed
    while (c == 0) {
        c = os_kbd_get_char();
    }
    
    // Clear any stale characters in the buffer first
    while(os_kbd_get_char() != 0);

    return c;
}

void os_set_char_xy(unsigned short x, unsigned short y)
{
    SYSCALL_PARAMS.param0 = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1 = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2 = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3 = (unsigned char)(y >> 8);

    __asm(" cop #0x0A\n");
}

void os_set_char_color(unsigned short newColor){
    SYSCALL_PARAMS_START = newColor;   // store to $0F00 in C
    __asm(" cop #0x17\n");   // COP #1
}

void os_draw_sprite32(unsigned short x, unsigned short y, unsigned short sprite_id)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  sprite_id_lo, sprite_id_hi

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(sprite_id & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(sprite_id >> 8);

    __asm(" cop #0x18\n");
}

void os_draw_sprite16(unsigned short x, unsigned short y, unsigned short sprite_id)
{
    
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 
    //                                  sprite_id_lo, sprite_id_hi

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(sprite_id & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(sprite_id >> 8);

    __asm(" cop #0x19\n");
}

void os_tile_backup_16(unsigned short x, unsigned short y)
{
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x1B\n");
}

void os_tile_backup_32(unsigned short x, unsigned short y)
{
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x1A\n");
}

void os_tile_restore_16(unsigned short x, unsigned short y)
{
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x1D\n");
}

void os_tile_restore_32(unsigned short x, unsigned short y)
{
    // Before calling, SYSCALL_PARAMS:  start_x_lo, start_x_hi, start_y_lo, start_y_hi, 

    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x1C\n");
}

char mouse_read_byte_c() {
    char data = 0;
    
    // 1. Wait for Start Bit (Clock low)
    while (VIA2_PORTB & 0x80); 

    // 2. Read 8 Data Bits
    for (int i = 0; i < 8; i++) {
        // Wait for Clock High
        while (!(VIA2_PORTB & 0x80));
        // Wait for Clock Low (Data is stable here)
        while (VIA2_PORTB & 0x80);
        
        data >>= 1;
        if (VIA2_PORTB & 0x40) { // Check PB6
            data |= 0x80;
        }
    }

    // 3. Skip Parity bit
    while (!(VIA2_PORTB & 0x80));
    while (VIA2_PORTB & 0x80);

    // 4. Skip Stop bit
    while (!(VIA2_PORTB & 0x80));
    while (VIA2_PORTB & 0x80);

    return data;
}

void os_draw_sprite8(unsigned short x, unsigned short y, unsigned short sprite_id)
{
    // SYSCALL_PARAMS: start_x_lo, start_x_hi, start_y_lo, start_y_hi, sprite_id_lo, sprite_id_hi
    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);
    SYSCALL_PARAMS.param4  = (unsigned char)(sprite_id & 0xFF);
    SYSCALL_PARAMS.param5  = (unsigned char)(sprite_id >> 8);

    __asm(" cop #0x1e\n");
}

void os_tile_backup_8(unsigned short x, unsigned short y)
{
    // SYSCALL_PARAMS: start_x_lo, start_x_hi, start_y_lo, start_y_hi
    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x1f\n");
}

void os_tile_restore_8(unsigned short x, unsigned short y)
{
    // SYSCALL_PARAMS: start_x_lo, start_x_hi, start_y_lo, start_y_hi
    SYSCALL_PARAMS.param0  = (unsigned char)(x & 0xFF);
    SYSCALL_PARAMS.param1  = (unsigned char)(x >> 8);
    SYSCALL_PARAMS.param2  = (unsigned char)(y & 0xFF);
    SYSCALL_PARAMS.param3  = (unsigned char)(y >> 8);

    __asm(" cop #0x20\n");
}

#define NES_LATCH 0x01 // PB0
#define NES_CLOCK 0x02 // PB1
#define NES_DATA  0x04 // PB2

unsigned char read_nes_gamepad_c()
{
    unsigned char gamepad_state = 0;

    // 1. Latch high
    VIA2_PORTB |= NES_LATCH;
    
    // Small delay for latch pulse width
    __asm(" nop\n nop\n nop\n");

    // 2. Latch low (freezes button states)
    VIA2_PORTB &= ~NES_LATCH;

    // 3. Loop through 8 buttons
    for (int i = 0; i < 8; i++) 
    {
        // Shift existing bits left to make room for the new bit
        gamepad_state <<= 1;

        // Read PB2. NES is Active Low (0 = Pressed).
        // If the bit is not set, the button is pressed.
        if (!(VIA2_PORTB & NES_DATA)) 
        {
            gamepad_state |= 0x01;
        }

        // Pulse Clock High
        VIA2_PORTB |= NES_CLOCK;
        
        // Pulse Clock Low (shifts to next bit on falling edge)
        VIA2_PORTB &= ~NES_CLOCK;
    }

    return gamepad_state;
}

void os_play_music(unsigned short music_id)
{
    //, unsigned short volume, unsigned char loop_flag

    // SYSCALL_PARAMS: music_id_lo, music_id_hi, volume, loop_flag
    SYSCALL_PARAMS.param0 = (unsigned char)(music_id & 0xFF);
    SYSCALL_PARAMS.param1 = (unsigned char)(music_id >> 8);
    //SYSCALL_PARAMS.param2 = (unsigned char)(volume & 0xFF);
    //SYSCALL_PARAMS.param3 = loop_flag;

    __asm(" cop #0x21\n");
}

void os_play_sfx(unsigned short sfx_id)
{
    SYSCALL_PARAMS.param0 = (unsigned char)(sfx_id & 0xFF);
    SYSCALL_PARAMS.param1 = (unsigned char)(sfx_id >> 8);

    __asm(" cop #0x22\n");
}
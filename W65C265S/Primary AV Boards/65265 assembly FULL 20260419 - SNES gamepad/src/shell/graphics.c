#include "graphics.h"
#include "util.h"
#include "os.h"
#include <stdlib.h> // For rand()

unsigned short time_remaining = 224;

const unsigned short rehsd_raw_565[1024] = {
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0020,0x18E3,0x2124,0x2985,0x3186,0x31A6,0x31A6,0x3186,0x2965,0x2124,0x18C3,0x0841,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0841,0x2104,0x39E7,0x4248,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4248,0x39E7,0x2104,0x0841,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0841,0x2104,0x39E7,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x52AA,0x4A69,0x4A69,0x4A69,0x39E7,0x18E3,0x0861,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0841,0x2965,0x4A49,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x738E,0xD6BA,0x4A69,0x4A69,0x4A69,0x4A69,0x4A49,0x2965,0x0020,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x1082,0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x73AE,0xE73C,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x31A6,0x0861,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0841,0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x73AE,0xE73C,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x31A6,0x0020,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0841,0x2985,0x4A69,0x4A69,0x52CA,0x528A,0x4A69,0x5ACB,0x528A,0x4A69,0x4A69,0x6B6D,0x7BEF,0x5ACB,0x4A69,0x4A69,0x73AE,0xE73C,0x528A,0x6B6D,0x73CE,0x528A,0x4A69,0x4A69,0x4A69,0x4A69,0x2965,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x2104,0x4A49,0x4A69,0x4A69,0xC658,0x9492,0xBE17,0xEF9D,0x94B2,0x4A69,0xB5D6,0xF7DE,0xF7DE,0xE75C,0x630C,0x4A69,0x73AE,0xE75C,0xBDF7,0xF7DE,0xFFFF,0xBDF7,0x4A69,0x4A69,0x4A69,0x4A69,0x4248,0x18C3,0x0000,0x0000,
    0x0000,0x0841,0x39E7,0x4A69,0x4A69,0x4A69,0xCE59,0xEF7D,0xDEFB,0xB5D6,0x8410,0x8430,0xE75C,0x6B6D,0x52AA,0xBE17,0xBDF7,0x4A69,0x73AE,0xF7DE,0xD6BA,0x7BEF,0xA534,0xEF9D,0x630C,0x4A69,0x4A69,0x4A69,0x4A69,0x39E7,0x0841,0x0000,
    0x0000,0x2104,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0xBDF7,0x4A89,0x4A69,0x4A69,0xC638,0x94B2,0x4A69,0x4A69,0x6B6D,0xEF7D,0x4A69,0x73AE,0xE75C,0x52AA,0x4A69,0x4A69,0xEF9D,0x738E,0x4A69,0x4A69,0x4A69,0x4A69,0x4A49,0x2124,0x0000,
    0x0020,0x39E7,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x528A,0xDF1B,0x8430,0x738E,0x738E,0x8410,0xF7BE,0x528A,0x73AE,0xE73C,0x4A69,0x4A69,0x4A69,0xDF1B,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x39C7,0x1082,
    0x18E3,0x4248,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x52AA,0xEF7D,0xEF9D,0xEF9D,0xEF9D,0xEF9D,0xEF9D,0x52AA,0x73AE,0xE73C,0x4A69,0x4A69,0x4A69,0xDEFB,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4228,0x1082,
    0x2124,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x52AA,0xE75C,0x632C,0x528A,0x528A,0x528A,0x528A,0x4A69,0x73AE,0xE73C,0x4A69,0x4A69,0x4A69,0xDEFB,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x18C3,
    0x2985,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x4A89,0xDEFB,0x7C0F,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x73AE,0xE73C,0x4A69,0x632C,0x528A,0xDEFB,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x2965,
    0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x4A69,0xB5D6,0xCE79,0x4A69,0x4A69,0x4A69,0x73AE,0x4A69,0x73AE,0xE73C,0x4A69,0xDF1B,0x6B6D,0xDEFB,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x3186,
    0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xCE59,0x8C71,0x4A69,0x4A69,0x4A69,0x6B6D,0xF7BE,0xC658,0x9CF3,0xBE17,0xEF7D,0x4A69,0x73AE,0xE73C,0x4A69,0xE73C,0x6B8D,0xDEFB,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x31A6,
    0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xAD95,0x7BEF,0x4A69,0x4A69,0x4A69,0x4A69,0x7BCF,0xDF1B,0xF7DE,0xDF1B,0x8C71,0x4A69,0x6B6D,0xC638,0x4A69,0xE73C,0x6B8D,0xBDF7,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x31A6,
    0x3186,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x6B4D,0x94D2,0x8C71,0x5B0B,0x4A69,0x4A69,0x4A69,0x7BEF,0x9CF3,0x73AE,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x3186,
    0x2965,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x7BCF,0xF7BE,0xEF9D,0xF7DE,0xEF9D,0x528A,0x4A69,0x94B2,0xF7DE,0xF7DE,0xF7DE,0xF7DE,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x2965,
    0x2124,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xD6BA,0xA554,0x4A69,0x5AEB,0xBDD7,0x528A,0x52AA,0xEF7D,0x9CF3,0x4A69,0x6B6D,0xEF9D,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x18C3,
    0x18C3,0x4248,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xEF9D,0x7BCF,0x4A69,0x4A69,0x4A69,0x4A69,0x8410,0xDF1B,0x4A89,0x4A69,0x4A69,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4228,0x1082,
    0x0841,0x39E7,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0xD6BA,0xD69A,0x6B8D,0x52AA,0x4A69,0x4A69,0xA534,0xBE17,0x4A69,0x4A69,0x4A69,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x31C6,0x0000,
    0x0000,0x2104,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x7BCF,0xEF9D,0xF7DE,0xE73C,0x8C51,0x4A69,0xB596,0xB5B6,0x4A69,0x4A69,0x4A69,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A49,0x2104,0x0000,
    0x0000,0x0020,0x39E7,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x5ACB,0x94D2,0xD6DA,0xF7BE,0x5AEB,0xAD75,0xBDF7,0x4A69,0x4A69,0x4A69,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x39E7,0x0020,0x0000,
    0x0000,0x0000,0x18E3,0x4A49,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x52CA,0xEF9D,0x73CE,0x9CD3,0xCE79,0x4A69,0x4A69,0x4A69,0xE73C,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4248,0x18C3,0x0000,0x0000,
    0x0000,0x0000,0x0861,0x2965,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A89,0x9CF3,0x4A89,0x4A69,0x5ACB,0xEF9D,0x6B8D,0x73AE,0xEF7D,0x5B0B,0x4A69,0x73AE,0xF7BE,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x4A49,0x2965,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0020,0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x4A89,0xF7BE,0xDEFB,0xB5D6,0xD6DA,0xD6DA,0x4A69,0x4A69,0xDEFB,0xE75C,0xD6BA,0xEF9D,0xF7BE,0x6B8D,0x4A69,0x4A69,0x4A69,0x4A69,0x3186,0x0020,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0861,0x31A6,0x4A69,0x4A69,0x4A69,0x4A69,0x73CE,0xC658,0xDF1B,0xBDF7,0x5ACB,0x4A69,0x4A69,0x6B4D,0xD6BA,0xD6DA,0x73AE,0xAD55,0x630C,0x4A69,0x4A69,0x4A49,0x3186,0x0861,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0020,0x2965,0x4248,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4248,0x2965,0x0020,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x18C3,0x39E7,0x4A49,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A49,0x39E7,0x18C3,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0841,0x2104,0x39C7,0x4228,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4A69,0x4228,0x31C6,0x2104,0x0020,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x1082,0x18C3,0x2965,0x3186,0x31A6,0x31A6,0x3186,0x2965,0x18C3,0x1082,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
};

void draw_logo_32_scaled_4x(short centerX, short centerY)
{
    short startX = centerX - 64; 
    short startY = centerY - 64;
    unsigned short i = 0;

    for (unsigned char y = 0; y < 32; y++) {
        for (unsigned char x = 0; x < 32; x++) {
            unsigned short c565 = rehsd_raw_565[i++];
            
            if (c565 != 0x0000) {
                // Convert 16-bit 565 to 8-bit 332
                // Red:   ((c >> 11) & 0x1F) -> scale to 3 bits
                // Green: ((c >> 5) & 0x3F)  -> scale to 3 bits
                // Blue:  (c & 0x1F)         -> scale to 2 bits
                unsigned char r = (unsigned char)((c565 >> 13) & 0x07);
                unsigned char g = (unsigned char)((c565 >> 8) & 0x07);
                unsigned char b = (unsigned char)((c565 >> 3) & 0x03);
                unsigned char c332 = (unsigned char)((r << 5) | (g << 2) | b);

                os_draw_rectangle(
                    (unsigned short)(startX + (x << 2)), 
                    (unsigned short)(startY + (y << 2)), 
                    4, 4, 
                    c332, 1
                );
            }
        }
        // One delay per row to keep the bus happy
        delay(3); 
    }
}

void draw_logo_32_scaled_2x(short centerX, short centerY)
{
    short startX = centerX - 32; 
    short startY = centerY - 32;
    unsigned short i = 0;

    for (unsigned char y = 0; y < 32; y++) {
        for (unsigned char x = 0; x < 32; x++) {
            unsigned short c565 = rehsd_raw_565[i++];
            
            if (c565 != 0x0000) {
                // Convert 16-bit 565 to 8-bit 332
                // Matches your specific bit-extraction logic
                unsigned char r = (unsigned char)((c565 >> 13) & 0x07);
                unsigned char g = (unsigned char)((c565 >> 8) & 0x07);
                unsigned char b = (unsigned char)((c565 >> 3) & 0x03);
                unsigned char c332 = (unsigned char)((r << 5) | (g << 2) | b);

                os_draw_rectangle(
                    (unsigned short)(startX + (x << 1)), 
                    (unsigned short)(startY + (y << 1)), 
                    2, 2, 
                    c332, 1
                );
            }
        }
        // Keep the bus happy with a row delay
        delay(3); 
    }
}

void gfxFrame1(unsigned char BLOCK)
{
    for (unsigned short y = 0; y < H; y += BLOCK) {
        unsigned short h = (y + BLOCK > H) ? (H - y) : BLOCK;

        for (unsigned short x = 0; x < W; x += BLOCK) {
            unsigned short w = (x + BLOCK > W) ? (W - x) : BLOCK;

            unsigned char v =
                (unsigned char)(((unsigned int)x + (unsigned int)y) & 0xFF);

            unsigned short c = rainbow332(v);

            os_draw_rectangle(x, y, w, h, c, 1);
        }
        
        delay(3);
    }
}

void simpleRectangles()
{
    os_draw_rectangle(100,40,100,10,RGB332_BLACK,1);
    os_draw_rectangle(100,50,100,10,RGB332_WHITE,1);    
    os_draw_rectangle(100,60,100,10,RGB332_RED,1);
    os_draw_rectangle(100,70,100,10,RGB332_GREEN,1);
    os_draw_rectangle(100,80,100,10,RGB332_BLUE,1);
    os_draw_rectangle(100,90,100,10,RGB332_CYAN,1);
    os_draw_rectangle(100,100,100,10,RGB332_MAGENTA,1);
    os_draw_rectangle(100,110,100,10,RGB332_YELLOW,1);
    os_draw_rectangle(100,120,100,10,RGB332_ORANGE,1);
    os_draw_rectangle(100,130,100,10,RGB332_PURPLE,1);
    os_draw_rectangle(100,140,100,10,RGB332_BROWN,1);
    os_draw_rectangle(100,150,100,10,RGB332_PINK,1);
    os_draw_rectangle(100,160,100,10,RGB332_GRAY,1);
    os_draw_rectangle(100,170,100,10,RGB332_DARK_GRAY,1);
    os_draw_rectangle(100,180,100,10,RGB332_LIGHT_GRAY,1);
}

void horizontalDot()
{
    os_draw_rectangle(0,200,5,5,RGB332_RED,1);
    for (unsigned short x = 0; x <= 320; x += 1) {
        delayms(5);
        os_draw_rectangle(x + 5, 200, 1, 5, RGB332_RED, 1);
        delayms(5);
        os_draw_rectangle(x, 200, 1, 5, RGB332_BLACK, 1);
    }
}

void diagonalColors()
{
    //gfxFrame1(8);
    gfxFrame1(4);
    //gfxFrame1(2);     
    //gfxFrame1(1);     // need more power, captain
}

void opening_window(unsigned char t)
{
    short centerX = 160;
    short centerY = 120;

    // 1. Calculate the Expanding Black Window bounds
    unsigned char size_step = (t % 6); 
    short w = (short)((size_step + 1) * 16);
    short h = (short)((size_step + 1) * 12);
    short x = centerX - (w >> 1);
    short y = centerY - (h >> 1);

    // 2. Draw the Black Window
    if (w <= 288 && h <= 216) {
        os_draw_rectangle((unsigned short)x, (unsigned short)y, (unsigned short)w, (unsigned short)h, 0x00, 1);
    }
   
}

void sprite_loop_test() {
    unsigned short x16 = 200;
    unsigned short y16 = 160;
    unsigned short id16 = 0;

    unsigned short x32 = 10;
    unsigned short y32 = 80;

    os_draw_rectangle(x16-2, y16-2, 2+16+2, 2+16+2, RGB332_LIGHT_GRAY, FILLED);
    os_draw_rectangle(x32-2, y32-2, 2+32+2, 2+32+2, RGB332_LIGHT_GRAY, FILLED);
    os_draw_rectangle(262-2, y32-2, 2+32+2, 2+32+2, RGB332_LIGHT_GRAY, FILLED);
    delay(100);
    os_draw_rectangle(x16-2, y16-2, 2+16+2, 2+16+2, RGB332_GRAY, FILLED);
    os_draw_rectangle(x32-2, y32-2, 2+32+2, 2+32+2, RGB332_GRAY, FILLED);
    os_draw_rectangle(262-2, y32-2, 2+32+2, 2+32+2, RGB332_GRAY, FILLED);
    delay(100);
    os_draw_rectangle(x16-2, y16-2, 2+16+2, 2+16+2, RGB332_DARK_GRAY, FILLED);
    os_draw_rectangle(x32-2, y32-2, 2+32+2, 2+32+2, RGB332_DARK_GRAY, FILLED);
    os_draw_rectangle(262-2, y32-2, 2+32+2, 2+32+2, RGB332_DARK_GRAY, FILLED);
    delay(100);
    os_draw_rectangle(x16-2, y16-2, 2+16+2, 2+16+2, RGB332_BLACK, FILLED);
    os_draw_rectangle(x32-2, y32-2, 2+32+2, 2+32+2, RGB332_BLACK, FILLED);
    os_draw_rectangle(262-2, y32-2, 2+32+2, 2+32+2, RGB332_BLACK, FILLED);

    // 16x16 moves left (ID 0-5), 32x32 moves right
    // Run 18 times (three cycles of ID 0-5)
    for (int i = 0; i < 18; i++) {
        id16 = i % 6; // Cycle 0, 1, 2, 3, 4, 5

        // Backup
        os_tile_backup_16(x16, y16);
        os_tile_backup_32(x32, y32);

        // Draw
        os_draw_sprite16(x16, y16, id16);
        os_draw_sprite32(x32, y32, 0);

        delayms(100); // Small delay to see the animation

        // Restore
        os_tile_restore_16(x16, y16);
        os_tile_restore_32(x32, y32);

        // Update Positions
        x16 -= 5;
        x32 += 7;
        
        // Edge check for 32x32 (approx 320 - width)
        if (x32 > 288) x32 = 10; 
    }

    // 16x16 moves right (ID 6-11), 32x32 continues moving right
    for (int i = 0; i < 18; i++) {
        id16 = 6 + (i % 6); // Cycle 6, 7, 8, 9, 10, 11

        os_tile_backup_16(x16, y16);
        os_tile_backup_32(x32, y32);

        os_draw_sprite16(x16, y16, id16);
        os_draw_sprite32(x32, y32, 0);

        delayms(100);

        os_tile_restore_16(x16, y16);
        os_tile_restore_32(x32, y32);

        x16 += 5;
        x32 += 7;

        if (x32 > 288) x32 = 10;
    }
}

void show_wait_for_key_box()
{
    os_draw_rectangle(69, 228, 182, 11, RGB332_BLACK, FILLED);
    os_draw_rectangle(70, 229, 180, 9, RGB332_DARK_GRAY, FILLED);

    os_set_char_color(RGB332_YELLOW);
    os_set_char_xy(76,230);
    os_puts("Press any key to continue...");
    os_kbd_wait_for_key();
    os_set_char_color(RGB332_GRAY);
    os_set_char_xy(76,230);
    os_puts("Press any key to continue...");
}

void draw_brick(unsigned short x, unsigned short y)
{
    os_draw_rectangle(x, y, 8, 8, RGB332_DARK_GRAY, FILLED);
    os_draw_rectangle(x, y, 7, 7, RGB332_LIGHT_GRAY, FILLED);
    os_draw_rectangle(x+1, y+1, 6, 6, RGB332_GRAY, FILLED);
}

void draw_brick_half(unsigned short x, unsigned short y)
{

    os_draw_line(x, y, x+1, y, RGB332_LIGHT_GRAY);

    os_draw_line(x, y+8, x+2, y+8, RGB332_DARK_GRAY);   // bottom dark edge
    os_draw_line(x+2, y, x+2, y+7, RGB332_DARK_GRAY);   // right dark edge

    os_draw_rectangle(x, y+1, 1, 6, RGB332_GRAY, FILLED);
}

void draw_cloud(){
    os_draw_circle(200, 50, 12, RGB332_BLACK, FILLED);
    
    os_draw_circle(208, 55, 12, RGB332_BLACK, FILLED);
    os_draw_circle(216, 60, 12, RGB332_BLACK, FILLED);
    os_draw_circle(224, 50, 12, RGB332_BLACK, FILLED);
    os_draw_circle(232, 55, 12, RGB332_BLACK, FILLED);
    
    os_draw_circle(208, 46, 12, RGB332_BLACK, FILLED);
    os_draw_circle(216, 42, 12, RGB332_BLACK, FILLED);
    os_draw_circle(224, 38, 12, RGB332_BLACK, FILLED);
    os_draw_circle(232, 45, 12, RGB332_BLACK, FILLED);

    os_draw_circle(240, 50, 12, RGB332_BLACK, FILLED);


    os_draw_circle(200, 50, 11, RGB332_WHITE, FILLED);
    
    os_draw_circle(208, 55, 11, RGB332_WHITE, FILLED);
    os_draw_circle(216, 60, 11, RGB332_WHITE, FILLED);
    os_draw_circle(224, 50, 11, RGB332_WHITE, FILLED);
    os_draw_circle(232, 55, 11, RGB332_WHITE, FILLED);
    
    os_draw_circle(208, 46, 11, RGB332_WHITE, FILLED);
    os_draw_circle(216, 42, 11, RGB332_WHITE, FILLED);
    os_draw_circle(224, 38, 11, RGB332_WHITE, FILLED);
    os_draw_circle(232, 45, 11, RGB332_WHITE, FILLED);

    os_draw_circle(240, 50, 11, RGB332_WHITE, FILLED);
}

void update_score(){
    char time_str[4]; // Buffer for 3 digits + null terminator

    os_set_char_xy(20,5);
    os_puts("MARIO");

    os_set_char_xy(20,13);
    os_puts("000000");

    os_set_char_xy(90,13);
    os_puts("O x00");

    os_set_char_xy(180,5);
    os_puts("WORLD");    
    os_set_char_xy(180,13);
    os_puts(" 1-1");    

    os_draw_rectangle(256, 13, 20, 8, RGB332_SKY_BLUE, FILLED); // Clear previous time
    os_set_char_xy(250,5);
    os_puts("TIME");    
    os_set_char_xy(256,13);
    // Convert the number to string and print it
    int_to_ascii(time_remaining, time_str);
    os_set_char_xy(256, 13);
    os_puts(time_str);
}

void map_test()
{
    unsigned short id16 = 0;
    unsigned short x = 5;

    os_set_char_color(RGB332_WHITE);

    os_draw_rectangle(0,0,319,239,RGB332_SKY_BLUE,FILLED);

    draw_cloud();

    draw_brick_half(0,160);
    for(int i = 0; i < 320; i+=10) {
        draw_brick(i,150);
        draw_brick(i+4,160);
    }

    update_score();
    
    for (int i = 0; i < 70; i++) {
        id16 = 6 + (i % 6); // Cycle 6, 7, 8, 9, 10, 11

        os_draw_rectangle(x-5, 133, 16, 16, RGB332_SKY_BLUE, FILLED); // Clear the sprite area
        os_draw_sprite16(x, 133, id16);
        delayms(100);
        x += 5;

        if(id16 == 11){
            time_remaining--;
            update_score();
        }
    }
}

void graphics_test()
{
    os_clear_screen();

    // primitive shapes
    for(unsigned int t = 20; t < 255; t+=15) {
        os_draw_rectangle(t, 20, 10, 10, t, UNFILLED);
    }
    for(unsigned int t = 20; t < 255; t+=15) {
        os_draw_rectangle(t, 40, 10, 10, t, FILLED);
    }
    for(unsigned int t = 25; t < 255; t+=15) {
        os_draw_circle(t, 60, 5, t, UNFILLED);
    }
    for(unsigned int t = 25; t < 255; t+=15) {
        os_draw_circle(t, 80, 5, t, FILLED);
    }
    for(unsigned int t = 25; t < 255; t+=15) {
         os_draw_diamond(t, 100, 5, t, UNFILLED);
    }
    for(unsigned int t = 25; t < 255; t+=15) {
        os_draw_diamond(t, 120, 5, t, FILLED);
    }

    for(int i = 140; i <= 200; i += 9) {
        os_draw_line(10, 170, 300, i, i);
    }

    // Text
    os_set_char_color(RGB332_PURPLE);
    os_set_char_xy(10,180);
    os_puts("Hello, World!");
    
    os_set_char_color(RGB332_PINK);
    os_set_char_xy(140,200);
    os_puts("Hola!");

    for (int y = 0; y < 100; y+=2) {
        os_set_char_color(RGB332_ORANGE);
        os_set_char_xy(270, y);
        os_puts("rehsd");

        delay(100);

        os_set_char_color(RGB332_BLACK);
        os_set_char_xy(270, y);
        os_puts("rehsd");
    }
    os_set_char_color(RGB332_ORANGE);
    os_set_char_xy(270, 98);
    os_puts("rehsd");

    show_wait_for_key_box();

    diagonalColors();
    delayms(50);
    
    draw_logo_32_scaled_4x(160, 120);
    delayms(50);

    // Transparent software sprites
    sprite_loop_test();
    show_wait_for_key_box();

    map_test();
    show_wait_for_key_box();

}

unsigned short rgb332(unsigned char r, unsigned char g, unsigned char b)
{
    // RRRGGGBB
    // Red:   Take top 3 bits (7,6,5), keep them at 7,6,5
    // Green: Take top 3 bits (7,6,5), shift right 3 to positions 4,3,2
    // Blue:  Take top 2 bits (7,6),   shift right 6 to positions 1,0
    
    unsigned short r_part = (unsigned short)(r & 0xE0);
    unsigned short g_part = (unsigned short)(g & 0xE0) >> 3;
    unsigned short b_part = (unsigned short)(b & 0xC0) >> 6;

    return (unsigned short)(r_part | g_part | b_part);
}

unsigned short rainbow332(unsigned char v)
{
    // high 3 bits choose a base hue (0–7)
    unsigned char band = v >> 5;        // 0..7
    unsigned char level = v & 0x1F;     // 0..31

    // scale level up to 0..255
    unsigned char l = (unsigned char)(level << 3);

    unsigned char r = 0, g = 0, b = 0;

    switch (band) {
        case 0: r = l;         g = 0;         b = 0;         break; // red
        case 1: r = l;         g = l >> 1;    b = 0;         break; // orange
        case 2: r = l;         g = l;         b = 0;         break; // yellow
        case 3: r = 0;         g = l;         b = 0;         break; // green
        case 4: r = 0;         g = l;         b = l;         break; // cyan
        case 5: r = 0;         g = 0;         b = l;         break; // blue
        case 6: r = l >> 1;    g = 0;         b = l;         break; // purple
        default:r = l;         g = 0;         b = l;         break; // magenta
    }

    return rgb332(r, g, b);
}

void start_windows()
{
    char menu_open = 0;

    os_draw_rectangle(0, 0, 319, 239, RGB332_SKY_BLUE, FILLED);
    os_draw_rectangle(0, 0, 319, 9, RGB332_WHITE, FILLED);
    os_draw_line(0, 10, 319, 10, RGB332_BLACK);

    // 'r' icon
        os_draw_pixel(5,3, RGB332_DARK_GRAY);
        os_draw_pixel(5,4, RGB332_DARK_GRAY);
        os_draw_pixel(5,5, RGB332_DARK_GRAY);

        os_draw_pixel(6,2, RGB332_DARK_GRAY);
        os_draw_pixel(6,3, RGB332_DARK_GRAY);
        os_draw_pixel(6,4, RGB332_DARK_GRAY);
        os_draw_pixel(6,5, RGB332_DARK_GRAY);
        os_draw_pixel(6,6, RGB332_DARK_GRAY);

        os_draw_pixel(7,1, RGB332_DARK_GRAY);
        os_draw_pixel(7,2, RGB332_WHITE);
        os_draw_pixel(7,3, RGB332_WHITE);
        os_draw_pixel(7,4, RGB332_WHITE);
        os_draw_pixel(7,5, RGB332_WHITE);
        os_draw_pixel(7,6, RGB332_WHITE);
        os_draw_pixel(7,7, RGB332_DARK_GRAY);

        os_draw_pixel(8,1, RGB332_DARK_GRAY);
        os_draw_pixel(8,2, RGB332_WHITE);
        os_draw_pixel(8,3, RGB332_DARK_GRAY);
        os_draw_pixel(8,4, RGB332_DARK_GRAY);
        os_draw_pixel(8,5, RGB332_DARK_GRAY);
        os_draw_pixel(8,6, RGB332_DARK_GRAY);
        os_draw_pixel(8,7, RGB332_DARK_GRAY);
        
        os_draw_pixel(9,1, RGB332_DARK_GRAY);
        os_draw_pixel(9,2, RGB332_DARK_GRAY);
        os_draw_pixel(9,3, RGB332_WHITE);
        os_draw_pixel(9,4, RGB332_DARK_GRAY);
        os_draw_pixel(9,5, RGB332_DARK_GRAY);
        os_draw_pixel(9,6, RGB332_DARK_GRAY);
        os_draw_pixel(9,7, RGB332_DARK_GRAY);

        os_draw_pixel(10,2, RGB332_DARK_GRAY);
        os_draw_pixel(10,3, RGB332_DARK_GRAY);
        os_draw_pixel(10,4, RGB332_DARK_GRAY);
        os_draw_pixel(10,5, RGB332_DARK_GRAY);
        os_draw_pixel(10,6, RGB332_DARK_GRAY);

        os_draw_pixel(11,3, RGB332_DARK_GRAY);
        os_draw_pixel(11,4, RGB332_DARK_GRAY);
        os_draw_pixel(11,5, RGB332_DARK_GRAY);

    os_set_char_color(RGB332_BLACK);
    os_set_char_xy(20, 1);
    os_puts("File ");
    os_puts("Edit ");
    os_puts("View ");
    os_puts("Special ");
    os_puts("Color ");


    mouse_x = 160;
    mouse_y = 120;

    int old_x = mouse_x;
    int old_y = mouse_y;

    // Initial draw
    os_tile_backup_8(mouse_x, mouse_y);
    os_draw_sprite8(mouse_x, mouse_y, SPRITE_8_MOUSE_POINTER);        // TO DO add constants

    while(1) {
        // Poll PB7 (Clock). If it's low, the mouse is sending data.
        if (!(VIA2_PORTB & 0x80)) {
            unsigned char b1 = mouse_read_byte_c();
            unsigned char b2 = mouse_read_byte_c();
            unsigned char b3 = mouse_read_byte_c();

            // 1. Convert to signed movement deltas
            signed char dx = (signed char)b2;
            signed char dy = (signed char)b3;

            // 2. Update coordinates
            mouse_x += (int)dx;
            mouse_y -= (int)dy;

            // 3. Constrain to bounds
            if (mouse_x < 0) mouse_x = 0;
            if (mouse_x > 311) mouse_x = 311; // 320 - 8 (for 8x8 sprite)
            if (mouse_y < 0) mouse_y = 0; 
            if (mouse_y > 231) mouse_y = 231; // 240 - 8

            // 4. Redraw cursor if moved
            if (mouse_x != old_x || mouse_y != old_y) {
                os_tile_restore_8(old_x, old_y);
                os_tile_backup_8(mouse_x, mouse_y);
                os_draw_sprite8(mouse_x, mouse_y, SPRITE_8_MOUSE_POINTER);

                old_x = mouse_x;
                old_y = mouse_y;
            }

            // 5. Check for Left Mouse Button Click (Bit 0 of Byte 1)
            if (b1 & 0x01) {
                // Check if over the "Apple/r" menu area (0-30 x, 0-10 y)
                if (mouse_x <= 30 && mouse_y <= 10 && menu_open == 0) {
                    // Temporarily hide cursor to draw under it
                    os_tile_restore_8(mouse_x, mouse_y);
                    
                    // Draw the dropdown "rect"
                    os_draw_rectangle(5, 11, 60, 40, RGB332_WHITE, FILLED);
                    os_draw_rectangle(5, 11, 60, 40, RGB332_BLACK, UNFILLED);

                    os_set_char_color(RGB332_BLACK);
                    os_set_char_xy(10, 14);
                    os_puts("About");
                    os_set_char_xy(10, 24);
                    os_puts("Exit");
                    
                    // Re-backup and re-draw cursor so it stays on top
                    os_tile_backup_8(mouse_x, mouse_y);
                    os_draw_sprite8(mouse_x, mouse_y, SPRITE_8_MOUSE_POINTER);

                    menu_open = 1;
                }
                // If menu is open and click is outside menu area, close it
                else if (menu_open == 1 && (mouse_x > 65 || mouse_y > 50)) {
                    os_tile_restore_8(mouse_x, mouse_y); // Hide cursor to erase under it
                    os_draw_rectangle(5, 11, 60, 40, RGB332_SKY_BLUE, FILLED); // Erase menu
                    os_tile_backup_8(mouse_x, mouse_y); // Re-backup cursor area
                    os_draw_sprite8(mouse_x, mouse_y, SPRITE_8_MOUSE_POINTER); // Redraw cursor

                    menu_open = 0;
                }
                else if (menu_open == 1 && mouse_x <= 65 && mouse_y <= 50) {
                    // Check if "About" was clicked
                    if (mouse_y >= 14 && mouse_y < 24) {
                        os_tile_restore_8(mouse_x, mouse_y); // Hide cursor to erase under it
                        os_draw_rectangle(5, 11, 60, 40, RGB332_SKY_BLUE, FILLED); // Erase menu
                        os_tile_backup_8(mouse_x, mouse_y); // Re-backup cursor area
                        os_draw_sprite8(mouse_x, mouse_y, SPRITE_8_MOUSE_POINTER); // Redraw cursor

                        menu_open = 0;

                        // Show about info (for demo, just a message box)
                        os_draw_rectangle(50, 50, 220, 50, RGB332_WHITE, FILLED);
                        os_draw_rectangle(50, 50, 220, 50, RGB332_BLACK, UNFILLED);
                        os_set_char_color(RGB332_BLACK);
                        os_set_char_xy(60, 60);
                        os_puts("R265Nibbler fancy GUI  :)");
                        os_set_char_xy(60, 80);
                        os_puts("Press any key to continue...");
                        os_kbd_wait_for_key();

                        // Erase about box
                        os_draw_rectangle(50, 50, 220, 50, RGB332_SKY_BLUE, FILLED);

                    }
                    // Check if "Exit" was clicked
                    else if (mouse_y >= 24 && mouse_y < 34) {
                        // For demo purposes we won't actually exit the program,
                        // but in a real application you would trigger an exit here.
                        return; // Exit the function to end the program
                    }
                }
            }
        }
    }
}

void start_shooter()
{
    os_clear_screen();
    
    nes_x = 160;
    nes_y = 120;
    int old_x = nes_x;
    int old_y = nes_y;
    int delay_counter;

    os_tile_backup_8(nes_x, nes_y);
    os_draw_sprite8(nes_x, nes_y, SPRITE_8_SHOOTER_CROSSHAIR);

    while(1) {
        unsigned char pad = read_nes_gamepad_c();

        if ((pad & 0xCF) || (nes_x != old_x) || (nes_y != old_y)) {
            
            os_tile_restore_8(old_x, old_y);

            if (pad & NES_UP)    nes_y--;
            if (pad & NES_DOWN)  nes_y++;
            if (pad & NES_LEFT)  nes_x--;
            if (pad & NES_RIGHT) nes_x++;

            if (nes_x < 0) nes_x = 0;
            if (nes_x > 312) nes_x = 312;
            if (nes_y < 0) nes_y = 0;
            if (nes_y > 232) nes_y = 232;

            if ((pad & NES_A) && !(pad & NES_B)) {
                os_draw_circle(nes_x, nes_y, 3, RGB332_RED, FILLED);
            }
            else if (!(pad & NES_A) && (pad & NES_B)) {
                os_draw_diamond(nes_x, nes_y, 3, RGB332_YELLOW, FILLED);
            }
            else if ((pad & NES_A) && (pad & NES_B)) {
                os_draw_rectangle(nes_x-2, nes_y-2, 5, 5, RGB332_CYAN, FILLED);
            }


            os_tile_backup_8(nes_x, nes_y);
            os_draw_sprite8(nes_x, nes_y, SPRITE_8_SHOOTER_CROSSHAIR);

            old_x = nes_x;
            old_y = nes_y;

            delayms(4);    // slow it down a bit so it's playable
        }

        if (pad & NES_START) 
        {
            os_clear_screen();

            // After clearing, the crosshair is gone from the screen.
            // 1. Re-grab the backup (which is now empty/black from the clear)
            os_tile_backup_8(nes_x, nes_y);

            // 2. Put the crosshair back on the clean screen
            os_draw_sprite8(nes_x, nes_y, SPRITE_8_SHOOTER_CROSSHAIR);

            // 3. Sync old coordinates just in case
            old_x = nes_x;
            old_y = nes_y;
        }
        
        if (pad & NES_SELECT) return;
    }
}


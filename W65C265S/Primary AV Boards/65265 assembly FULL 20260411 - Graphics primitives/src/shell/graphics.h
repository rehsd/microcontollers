#ifndef GRAPHICS_H
#define GRAPHICS_H

// Constants
#define W 320
#define H 240
#define FILLED 1
#define UNFILLED 0

// Colors       3-bit Red, 3-bit Green, 2-bit Blue
#define RGB332_BLACK        0x00    // 000 000 00
#define RGB332_WHITE        0xFF    // 111 111 11
#define RGB332_RED          0xE0    // 111 000 00
#define RGB332_GREEN        0x1C    // 000 111 00
#define RGB332_DARK_GREEN   0x10    // 000 100 00
#define RGB332_BLUE         0x03    // 000 000 11
#define RGB332_CYAN         0x1F    // 000 111 11
#define RGB332_MAGENTA      0xE3    // 111 000 11
#define RGB332_YELLOW       0xFC    // 111 111 00
#define RGB332_ORANGE       0xF0    // 111 100 00
#define RGB332_PURPLE       0x83    // 100 000 11
#define RGB332_BROWN        0xA4    // 101 001 00
#define RGB332_PINK         0xE7    // 111 001 11
#define RGB332_GRAY         0x92    // 100 100 10
#define RGB332_DARK_GRAY    0x49    // 010 010 01
#define RGB332_LIGHT_GRAY   0xDB    // 110 110 11
#define RGB332_SKY_BLUE     0x6F    // 001 001 11


// Function Prototypes
void draw_logo_32_scaled_4x(short centerX, short centerY);
void draw_logo_32_scaled_2x(short centerX, short centerY);
void gfxFrame1(unsigned char BLOCK);
void simpleRectangles();
void horizontalDot();
void diagonalColors();
void opening_window(unsigned char t);
void graphics_test();
unsigned short rgb332(unsigned char r, unsigned char g, unsigned char b);
unsigned short rainbow332(unsigned char v);


#endif
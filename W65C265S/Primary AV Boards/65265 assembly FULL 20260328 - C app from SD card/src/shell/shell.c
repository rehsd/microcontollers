#include "../include/calypsi_intellisense_fix.h"
#include <calypsi/intrinsics65816.h>

#define SYSCALL_PARAMS_START (*(volatile unsigned char*)0x0F00)
#define SYSCALL_PARAMS_RESULT (*(volatile unsigned char*)0x0FFE)
#define SDCARD_RAM_BUFFER ((volatile unsigned char*)0x1200)

#define W 320
#define H 240

static const char hex_digits[] = "0123456789ABCDEF";

// Colors       3-bit Red, 3-bit Green, 2-bit Blue
#define RGB332_BLACK        0x00    // 000 000 00
#define RGB332_WHITE        0xFF    // 111 111 11
#define RGB332_RED          0xE0    // 111 000 00
#define RGB332_GREEN        0x1C    // 000 111 00
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

#pragma pack(push, 1)
typedef struct {
    unsigned char  bootstrap[446];
    unsigned char  partition1[16]; // We'll just look at the first one
    // ... other partitions ...
    unsigned short signature;      // Should be 0xAA55
} MBR_t;

typedef struct {
    unsigned char  jump[3];
    unsigned char  oem_name[8];
    unsigned short bytes_per_sector;
    unsigned char  sectors_per_cluster;
    unsigned short reserved_sectors;
    unsigned char  fat_count;
    unsigned short root_entry_count;
    unsigned short total_sectors_16;
    unsigned char  media_type;
    unsigned short sectors_per_fat;
    // ... more follows, but these are enough to find the Root Dir
} BPB_t;

typedef struct {
    char           filename[8];
    char           extension[3];
    unsigned char  attributes;
    unsigned char  reserved;
    unsigned char  create_time_ms;
    unsigned short create_time;
    unsigned short create_date;
    unsigned short last_access_date;
    unsigned short reserved_fat32;
    unsigned short write_time;
    unsigned short write_date;
    unsigned short start_cluster;
    unsigned long  file_size;
} DirectoryEntry_t;
#pragma pack(pop)

#define ATTR_READ_ONLY 0x01
#define ATTR_HIDDEN    0x02
#define ATTR_SYSTEM    0x04
#define ATTR_VOLUME_ID 0x08
#define ATTR_DIRECTORY 0x10
#define ATTR_ARCHIVE   0x20
#define ATTR_LONG_NAME 0x0F

// Global FAT16 state
static unsigned char  g_fat_initialized;
static unsigned short g_fat_size;  // Sectors per FAT
static unsigned long  g_partition_lba_start;
static unsigned short g_rsvd_sec_cnt;      // BPB_RsvdSecCnt
static unsigned short g_fat_size_sectors;  // BPB_FATSz16
static unsigned char  g_num_fats;          // BPB_NumFATs
static unsigned short g_root_entries;      // BPB_RootEntCnt
static unsigned long  g_root_lba_start;
static unsigned short g_root_sz_sects;
static unsigned long  g_data_lba_start;
static unsigned char  g_sectors_per_cluster;


static inline unsigned short rgb332(unsigned char r, unsigned char g, unsigned char b)
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

static inline unsigned short rainbow332(unsigned char v)
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

static inline void os_print_char(char c)
{
    SYSCALL_PARAMS_START = c;   // store to $0F00 in C
    //__asm(" .byte 0x02, 0x01\n");   // COP #1
    __asm(" cop #1\n");   // COP #1
}

static inline void os_newline(void)
{
    __asm(" cop #2\n");   // COP #2
}

static inline void os_debug_mark(void)
{
    __asm(" cop #3\n");   // COP #3
}

static inline void os_debug_mark2(void)
{
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

static inline void os_draw_rectangle(unsigned short x, unsigned short y, unsigned short width, 
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

static inline unsigned char sdcard_init()
{
    __asm(" cop #13\n");   // COP #13 ($0D)
    return SYSCALL_PARAMS_RESULT;
}

static inline int sdcard_read_sector(unsigned long block_num)
{
    // buffer to store 512 bytes of data read from the SD card block: SDCARD_RAM_BUFFER
    //SYSCALL_PARAMS_START = block_num;
    (*(volatile unsigned long*)0x0F00) = block_num;
    __asm(" cop #11\n");   // COP #11 ($0B)
    // SDCARD_RAM_BUFFER now has 512 bytes of data from the SD card block specified by block_num
    return SYSCALL_PARAMS_RESULT;
}

static inline int sdcard_write_sector(unsigned long block_num)
{
    // buffer to read from RAM and write the SD card block: SDCARD_RAM_BUFFER
    //SYSCALL_PARAMS_START = block_num;
    (*(volatile unsigned long*)0x0F00) = block_num;
    __asm(" cop #12\n");   // COP #12 ($0C)
    return SYSCALL_PARAMS_RESULT;
}

static void delay(long counts) {
    volatile long i;
    volatile long j;

    for (i = 0; i < counts; i++) {
        for (j = 0; j < 100; j++) {
            // volatile ensures the compiler doesn't 
            // delete this "useless" loop.
        }
    }
}

static void delayms(unsigned short ms) {
    volatile unsigned short i;
    volatile unsigned short j;

    for (i = 0; i < ms; i++) {
        for (j = 0; j < 588; j++) {
            // Approximately 1ms per 'i' iteration at 10MHz
        }
    }
}

static const unsigned short rehsd_raw_565[1024] = {
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
    gfxFrame1(8);
    gfxFrame1(4);
    //gfxFrame1(2);     
    //gfxFrame1(1);     need more power, captain
}

void opening_window(unsigned char t)
{
    short centerX = 160;
    short centerY = 120;

    // 1. Calculate the Expanding Black Window bounds
    unsigned char size_step = (t % 18); 
    short w = (short)((size_step + 1) * 16);
    short h = (short)((size_step + 1) * 12);
    short x = centerX - (w >> 1);
    short y = centerY - (h >> 1);

    // 2. Draw the Black Window
    if (w <= 288 && h <= 216) {
        os_draw_rectangle((unsigned short)x, (unsigned short)y, (unsigned short)w, (unsigned short)h, 0x00, 1);
    }
   
}

void graphics_test()
{
    simpleRectangles();
    delayms(10);

    horizontalDot();
    delayms(50);

    diagonalColors();
    delayms(50);

    
    unsigned char t = 0;
    while (t < 18) {
        opening_window(t++);
    }
    delayms(50);

    draw_logo_32_scaled_4x(160, 120);
    delayms(50);
}

void print_hex(unsigned char val)
{
    // Force 24-bit addressing for the lookup table
    // This prevents reading 'garbage' from the code bank (Bank 01)
    static const char __far hex_digits_far[] = "0123456789ABCDEF";
    
    unsigned char high = (val >> 4) & 0x0f;
    unsigned char low = val & 0x0f;
    
    os_print_char(hex_digits_far[high]);
    os_print_char(hex_digits_far[low]);
}

void print_hex32(unsigned long val)
{
    for (int shift = 28; shift >= 0; shift -= 4) {
        unsigned char nib = (val >> shift) & 0x0F;
        os_print_char(hex_digits[nib]);
    }
}

void fat_debug_print()
{
    os_puts("part_lba_start: ");        print_hex32(g_partition_lba_start);
    os_puts("  rsvd_sec_cnt:     ");    print_hex32(g_rsvd_sec_cnt);            os_newline();
    os_puts("fat_size_secs:  ");        print_hex32(g_fat_size_sectors);
    os_puts("  root_sz_secs:     ");    print_hex32(g_root_sz_sects);           os_newline();
    os_puts("data_lba_start: ");        print_hex32(g_data_lba_start);
    os_puts("  secs_per_cluster: ");    print_hex32(g_sectors_per_cluster);     os_newline();
}

void format_fat_name(const char* input, char* output)
{
    // Fill with spaces
    for (char i = 0; i < 11; i++)
        output[i] = ' ';

    int i = 0;
    int name_pos = 0;
    int ext_pos  = 0;
    int in_ext   = 0;

    while (input[i] != '\0') {
        char c = input[i++];

        if (c == '.') {
            in_ext = 1;
            continue;
        }

        if (c >= 'a' && c <= 'z') c -= 32;

        if (!in_ext) {
            if (name_pos < 8) output[name_pos++] = c;
        } else {
            if (ext_pos < 3) {
                output[8 + ext_pos] = c; // Explicit index
                ext_pos++;
            }
        }
    }
}

unsigned short rd16(int off)
{
    return (unsigned short)(
        ((unsigned short)SDCARD_RAM_BUFFER[off]) |
        ((unsigned short)SDCARD_RAM_BUFFER[off+1] << 8)
    );
}

unsigned long rd32(int off)
{
    return  ((unsigned long)SDCARD_RAM_BUFFER[off]) |
           ((unsigned long)SDCARD_RAM_BUFFER[off+1] << 8) |
           ((unsigned long)SDCARD_RAM_BUFFER[off+2] << 16) |
           ((unsigned long)SDCARD_RAM_BUFFER[off+3] << 24);
}

unsigned char fat_init(void)
{
    g_fat_initialized = 0;

    if (sdcard_init() != 0) return 1;

    // --- MBR ---
    if (sdcard_read_sector(0) != 0) return 2;

    g_partition_lba_start = rd32(446 + 8);

    // --- BPB ---
    if (sdcard_read_sector(g_partition_lba_start) != 0) return 3;

    g_rsvd_sec_cnt        = rd16(14);   // BPB_RsvdSecCnt
    g_sectors_per_cluster = SDCARD_RAM_BUFFER[13]; // BPB_SecPerClus
    g_fat_size_sectors    = rd16(22);   // BPB_FATSz16

    unsigned short root_entries = rd16(17); // BPB_RootEntCnt
    g_root_sz_sects = (root_entries * 32 + 511) / 512;

    unsigned long fat1_lba = g_partition_lba_start + g_rsvd_sec_cnt;
    unsigned long fat2_lba = fat1_lba + g_fat_size_sectors;

    g_root_lba_start = fat2_lba + g_fat_size_sectors;
    g_data_lba_start = g_root_lba_start + g_root_sz_sects;

    g_fat_initialized = 1;

    // debug
    fat_debug_print();

    return 0;
}

void list_root_directory()
{
    /*
     * Iterates through the root directory and displays entries.
     * Reads directory sectors from the SD card and parses 32-byte entries. 
     * Filters out deleted files and long-filename entries, then formats 
     * and displays Volume labels, Directories, and Files.
     */   

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    os_puts("Listing Directory:");
    os_newline();

    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) {
            os_puts("Dir Read Error");
            os_newline();
            break;
        }

        DirectoryEntry_t *entries = (DirectoryEntry_t*)SDCARD_RAM_BUFFER;

        for (char i = 0; i < 16; i++) {
            unsigned char first_char = entries[i].filename[0];

            if (first_char == 0x00) return;
            if (first_char == (char)0xE5) continue;
            if (entries[i].attributes == ATTR_LONG_NAME) continue;

            // Handle Volume Label
            if (entries[i].attributes & ATTR_VOLUME_ID) {
                os_puts("<VOL> ");
                for (char j = 0; j < 11; j++) {
                    // Volume IDs use the full 11 bytes (8 filename + 3 extension)
                    char c = ((char*)entries[i].filename)[j];
                    if (c != ' ') os_print_char(c);
                }
                os_newline();
                continue; // Move to next entry
            }

            // Handle Directories
            if (entries[i].attributes & ATTR_DIRECTORY) {
                os_puts("<DIR> ");
            } else {
                os_puts("      ");
            }

            // Print Filename
            for (char j = 0; j < 8; j++) {
                if (entries[i].filename[j] != ' ') os_print_char(entries[i].filename[j]);
            }

            // Print Extension
            if (entries[i].extension[0] != ' ') {
                os_print_char('.');
                for (char j = 0; j < 3; j++) {
                    if (entries[i].extension[j] != ' ') os_print_char(entries[i].extension[j]);
                }
            }
            os_newline();
        }
    }
}

void print_file_contents(const char* filename_with_ext)
{
    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    char target_fat_name[12]; // Increased to 12 for safety
    unsigned short start_cluster = 0;
    unsigned long  file_size = 0;
    unsigned char  found = 0;

    format_fat_name(filename_with_ext, target_fat_name);

    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        unsigned long lba = g_root_lba_start + s;
        if (sdcard_read_sector(lba) != 0) break;

        for (char i = 0; i < 16; i++) {
            // Calculate raw offset in the 512-byte buffer (32 bytes per entry)
            unsigned short entry_off = i * 32;
            unsigned char first = SDCARD_RAM_BUFFER[entry_off];

            if (first == 0x00) { s = g_root_sz_sects; break; } // End of dir
            if (first == 0xE5) continue;                       // Skip deleted

            // Check attributes at offset 11
            unsigned char attr = SDCARD_RAM_BUFFER[entry_off + 11];
            if (attr & (0x08 | 0x10)) continue;

            // MANUAL 11-BYTE COMPARISON (Raw Buffer Access)
            unsigned char match = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[entry_off + k] != (unsigned char)target_fat_name[k]) {
                    match = 0;
                    break;
                }
            }

            if (match) {
                // Extract cluster from offsets 26 and 27
                start_cluster = (unsigned short)(SDCARD_RAM_BUFFER[entry_off + 26] | 
                                (SDCARD_RAM_BUFFER[entry_off + 27] << 8));
                
                // Extract file size from offsets 28-31
                file_size = (unsigned long)SDCARD_RAM_BUFFER[entry_off + 28] |
                            ((unsigned long)SDCARD_RAM_BUFFER[entry_off + 29] << 8) |
                            ((unsigned long)SDCARD_RAM_BUFFER[entry_off + 30] << 16) |
                            ((unsigned long)SDCARD_RAM_BUFFER[entry_off + 31] << 24);

                found = 1;
                break;
            }
        }
        if (found) break;
    }

    if (!found) {
        os_puts("Error: File not found.");
        os_newline();
        return;
    }

    // 3. Read and Print the first cluster
    unsigned long file_lba = g_data_lba_start + 
                             ((unsigned long)(start_cluster - 2) * g_sectors_per_cluster);

    if (sdcard_read_sector(file_lba) == 0) {
        os_puts("--- ");
        os_puts(filename_with_ext);
        os_puts(" ---");
        os_newline();

        // Limit to one sector (512 bytes) for now
        unsigned int limit = (file_size > 512) ? 512 : (unsigned int)file_size;
        for (unsigned int i = 0; i < limit; i++) {
            os_print_char(SDCARD_RAM_BUFFER[i]);
        }
        os_newline();
        os_puts("------------------");
        os_newline();
    } else {
        os_puts("Read Error.");
        os_newline();
    }
}

signed char delete_file(const char* filename)
{
    if (!g_fat_initialized) return -1;

    char target_name[16]; 
    format_fat_name(filename, target_name);

    // Print what we are looking for
    // for(char j=0; j<11; j++) os_print_char(target_name[j]);

    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        unsigned long dir_lba = g_root_lba_start + s;
        if (sdcard_read_sector(dir_lba) != 0) return -2;

        for (char i = 0; i < 16; i++) {
            // Calculate raw offset in the 512-byte buffer (32 bytes per entry)
            unsigned short entry_offset = i * 32;
            unsigned char first_char = SDCARD_RAM_BUFFER[entry_offset];

            if (first_char == 0x00) return -3; // End of Dir
            if (first_char == 0xE5) continue; // Already deleted

            // Check attributes (offset 11 in the 32-byte entry)
            unsigned char attr = SDCARD_RAM_BUFFER[entry_offset + 11];
            if (attr & 0x18) continue; // Skip Volume/Dir

            // MANUAL 11-BYTE COMPARISON (No Structs)
            unsigned char match = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[entry_offset + k] != (unsigned char)target_name[k]) {
                    match = 0;
                    break;
                }
            }

            if (match) {
                os_puts("Existing file found - deleting...");
                os_newline();

                // Get start_cluster (offsets 26 and 27 in the entry)
                unsigned short cluster = (unsigned short)(SDCARD_RAM_BUFFER[entry_offset + 26] | 
                                         (SDCARD_RAM_BUFFER[entry_offset + 27] << 8));
                
                // 1. Mark as deleted in buffer and commit
                SDCARD_RAM_BUFFER[entry_offset] = 0xE5;
                if (sdcard_write_sector(dir_lba) != 0) return -4;

                // 2. Free the FAT chain
                if (cluster >= 2) {
                    unsigned long fat1_lba = g_partition_lba_start + g_rsvd_sec_cnt;
                    unsigned long fat2_lba = fat1_lba + g_fat_size_sectors;
                    
                    unsigned short fat_sector_offset = cluster / 256;
                    unsigned short ent_offset = (cluster % 256) * 2;

                    if (sdcard_read_sector(fat1_lba + fat_sector_offset) == 0) {
                        SDCARD_RAM_BUFFER[ent_offset] = 0x00;
                        SDCARD_RAM_BUFFER[ent_offset + 1] = 0x00;

                        sdcard_write_sector(fat1_lba + fat_sector_offset);
                        sdcard_write_sector(fat2_lba + fat_sector_offset);
                    }
                }
                return 0; 
            }
        }
    }
    //return -3; 
    return 0; // Not found, but not an error for delete operation
}

static inline void copy_bytes(unsigned char* dst, const unsigned char* src, unsigned short count)
{
    while (count--) {
        *dst++ = *src++;
    }
}

static inline void clear_bytes(unsigned char* dst, unsigned short count)
{
    while (count--) {
        *dst++ = 0;
    }
}

static inline void copy512(unsigned char* dst, const unsigned char* src)
{
    for (unsigned short i = 0; i < 512; i++) {
        dst[i] = src[i];
    }
}

static unsigned char bcd_to_bin(unsigned char bcd)
{
    // Convert BCD (e.g., 0x26) to standard Integer (26)
    return ((bcd >> 4) * 10) + (bcd & 0x0F);
}

static void get_system_time_fat(unsigned short* fat_date, unsigned short* fat_time) {
    __asm(" cop #14\n");   // #$0E 

    // Extract from SYSCALL_PARAMS using your macro and offsets
    // Order: Y=0, M=1, D=2, H=3, M=4, S=5
    unsigned char year  = bcd_to_bin((&SYSCALL_PARAMS_START)[0]); 
    unsigned char month = bcd_to_bin((&SYSCALL_PARAMS_START)[1]);
    unsigned char day   = bcd_to_bin((&SYSCALL_PARAMS_START)[2]);
    unsigned char hour  = bcd_to_bin((&SYSCALL_PARAMS_START)[3]);
    unsigned char min   = bcd_to_bin((&SYSCALL_PARAMS_START)[4]);
    unsigned char sec   = bcd_to_bin((&SYSCALL_PARAMS_START)[5]);

    // Pack for FAT (Year offset from 1980)
    // 2026 (26) + 20 = 46 years since 1980
    *fat_date = ((unsigned short)(year + 20) << 9) | 
                ((unsigned short)month << 5) | 
                (unsigned short)day;

    // Seconds are stored in 2-second increments (0-29)
    *fat_time = ((unsigned short)hour << 11) | 
                ((unsigned short)min << 5) | 
                (unsigned short)(sec / 2);
}

static signed char allocate_cluster(unsigned short* out_cluster)
{
    unsigned long fat1_lba = g_partition_lba_start + g_rsvd_sec_cnt;
    unsigned long fat2_lba = fat1_lba + g_fat_size_sectors;

    unsigned short cluster = 0;  // FAT entry index == cluster number

    for (unsigned short s = 0; s < g_fat_size_sectors; s++) {

        if (sdcard_read_sector(fat1_lba + s) != 0)
            return -1;

        for (unsigned short i = 0; i < 256; i++, cluster++) {

            unsigned short off = (unsigned short)(i * 2);
            unsigned short val =
                (unsigned short)(SDCARD_RAM_BUFFER[off] |
                                (SDCARD_RAM_BUFFER[off + 1] << 8));

            // skip reserved clusters 0 and 1
            if (cluster < 2)
                continue;

            if (val == 0x0000) {
                // mark as end-of-chain
                SDCARD_RAM_BUFFER[off]     = 0xFF;
                SDCARD_RAM_BUFFER[off + 1] = 0xFF;

                if (sdcard_write_sector(fat1_lba + s) != 0)
                    return -2;
                if (sdcard_write_sector(fat2_lba + s) != 0)
                    return -3;

                *out_cluster = cluster;
                return 0;
            }
        }
    }

    return -4; // no free clusters
}

signed char create_file(const char* filename, const char* content)
{
    if (!g_fat_initialized) return -1;

    // 1. Always attempt to delete existing file first
    delete_file(filename);

    char fat_name[16]; 
    format_fat_name(filename, fat_name);

    // 2. Allocate a single cluster
    unsigned short new_cluster;
    if (allocate_cluster(&new_cluster) != 0)
        return -2;

    // 3. Prepare and write the data sector
    for (unsigned short i = 0; i < 512; i++)
        SDCARD_RAM_BUFFER[i] = 0;

    int len = 0;
    while (content[len] != '\0' && len < 512) {
        SDCARD_RAM_BUFFER[len] = (unsigned char)content[len];
        len++;
    }

    unsigned long data_lba = g_data_lba_start + 
                             ((unsigned long)(new_cluster - 2) * g_sectors_per_cluster);

    if (sdcard_write_sector(data_lba) != 0)
        return -3;

    // 4. Find a free root directory entry slot
    unsigned long target_lba = 0;
    int target_idx = -1;

    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        unsigned long lba = g_root_lba_start + s;
        if (sdcard_read_sector(lba) != 0) return -4;

        for (char i = 0; i < 16; i++) {
            unsigned short entry_off = i * 32;
            unsigned char first = SDCARD_RAM_BUFFER[entry_off];

            if (first == 0x00 || first == 0xE5) {
                target_lba = lba;
                target_idx = i;
                s = g_root_sz_sects; 
                break;
            }
        }
    }

    if (target_idx < 0) return -5;

    // 5. Commit the directory entry using raw offsets
    if (sdcard_read_sector(target_lba) != 0) return -6;

    unsigned short entry_off = target_idx * 32;

    // Zero out the 32-byte slot first
    for (char j = 0; j < 32; j++) {
        SDCARD_RAM_BUFFER[entry_off + j] = 0;
    }

    // Write Name (8 bytes) and Extension (3 bytes)
    for (char j = 0; j < 8; j++) SDCARD_RAM_BUFFER[entry_off + j] = (unsigned char)fat_name[j];
    for (char j = 0; j < 3; j++) SDCARD_RAM_BUFFER[entry_off + 8 + j] = (unsigned char)fat_name[8 + j];

    // Attributes (Offset 11) - 0x20 = Archive
    SDCARD_RAM_BUFFER[entry_off + 11] = 0x20;

    // --- TIMESTAMPS ---
    unsigned short f_date, f_time;
    get_system_time_fat(&f_date, &f_time);

    // Creation Time (14-15) and Date (16-17)
    SDCARD_RAM_BUFFER[entry_off + 14] = (unsigned char)(f_time & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 15] = (unsigned char)(f_time >> 8);
    SDCARD_RAM_BUFFER[entry_off + 16] = (unsigned char)(f_date & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 17] = (unsigned char)(f_date >> 8);

    // Last Access Date (18-19)
    SDCARD_RAM_BUFFER[entry_off + 18] = (unsigned char)(f_date & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 19] = (unsigned char)(f_date >> 8);

    // Last Modified Time (22-23) and Date (24-25)
    SDCARD_RAM_BUFFER[entry_off + 22] = (unsigned char)(f_time & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 23] = (unsigned char)(f_time >> 8);
    SDCARD_RAM_BUFFER[entry_off + 24] = (unsigned char)(f_date & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 25] = (unsigned char)(f_date >> 8);

    // Start Cluster (Offsets 26, 27)
    SDCARD_RAM_BUFFER[entry_off + 26] = (unsigned char)(new_cluster & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 27] = (unsigned char)(new_cluster >> 8);

    // File Size (Offsets 28, 29, 30, 31)
    SDCARD_RAM_BUFFER[entry_off + 28] = (unsigned char)(len & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 29] = (unsigned char)((len >> 8) & 0xFF);

    // Final write back to the Root Directory
    if (sdcard_write_sector(target_lba) != 0) return -7;

    return 0;
}

void fat16_test()
{
    // -------------------------------------------
    //  INIT
    // -------------------------------------------
    os_puts("Initializing SD card... ");
    os_newline();
    char result = sdcard_init();
    if (result == 0) {
        os_puts("SD card initialized successfully!");
        os_newline();
    } else {
        os_puts("SD card initialization failed with error code: ");
        print_hex(result);
        os_newline();
        return;
    }

    // -------------------------------------------
    //  READ TEST
    // -------------------------------------------
    os_puts("Reading sector 0x0000 from SD card... ");
    os_newline();
    // Buffer to hold the sector data is SDCARD_RAM_BUFFER
    result = sdcard_read_sector(0x0000);
    if (result == 0) {
        os_puts("Sector read successfully! First 16 bytes:");
        os_newline();
        for (char i = 0; i < 16; i++) {
            print_hex(SDCARD_RAM_BUFFER[i]);
            os_print_char(' ');
        }
        os_newline();
    } else {
        os_puts("Sector read failed with error code: ");
        print_hex(result);
        os_newline();
        return;
    }

    // -------------------------------------------
    //  WRITE TEST
    // -------------------------------------------
    
    // PREPARE DATA
    os_puts("Preparing test data in buffer...");
    for (unsigned int i = 0; i < 512; i++) {
        SDCARD_RAM_BUFFER[i] = (unsigned char)(i & 0xFF); // Pattern 00, 01, 02...
    }
    os_newline();

    // WRITE SECTOR
    os_puts("Writing to sector 0x0020... ");
    os_newline();
    result = sdcard_write_sector(0x00000020);
    if (result == 0) {
        os_puts("Write command accepted!");
    } else {
        os_puts("Write failed! Error: ");
        print_hex(result);
        os_newline();
        return;
    }
    os_newline();

    // CLEAR BUFFER
    // Clear it so we know the next read is "fresh" and not just old RAM
    for (char i = 0; i < 16; i++) SDCARD_RAM_BUFFER[i] = 0x00;

    // READ BACK & VERIFY
    os_puts("Reading back sector 0x0020... ");
    os_newline();
    result = sdcard_read_sector(0x00000020);
    
    if (result == 0) {
        os_puts("Sector read successfully! First 16 bytes:");
        os_newline();
        for (char i = 0; i < 16; i++) {
            print_hex(SDCARD_RAM_BUFFER[i]);
            os_print_char(' ');
        }
    } else {
        os_puts("Read back failed!");
    }
    os_newline();

    // -------------------------------------------
    //  LIST CONTENTS OF ROOT DIRECTORY,
    //  PRINT A FILE'S CONTENTS, AND CREATE A FILE
    // -------------------------------------------
    if (fat_init() == 0) {
        os_puts("FAT16 System Ready");
        os_newline();
        
        list_root_directory();
        print_file_contents("FILE1.TXT");

        // Create a file
        result = create_file("hello.txt", "Hello from R265Nibbler!");
        if (result == 0) {
            os_puts("Success: File created.");
        } else {
            os_puts("Error: File creation failed code: ");
            print_hex(result);
        }
        os_newline();
    } else {
        os_puts("FAT16 Init Failed.");
        os_newline();
    }  

}


static char target_fat_name[16]; 


// Helper to convert hex ASCII to a byte
static unsigned char hex_to_byte(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    return 0;
}

// Reads two ASCII chars and returns a byte, advancing the pointer
static unsigned char get_hex_pair(const char **ptr) {
    unsigned char val = (hex_to_byte(**ptr) << 4);
    (*ptr)++;
    val |= hex_to_byte(**ptr);
    (*ptr)++;
    return val;
}

static unsigned long load_hex_from_sd(const char* filename) {
    static unsigned short start_cluster = 0;
    static unsigned long file_size = 0;
    static unsigned char found = 0;
    static unsigned short s = 0, i = 0, k = 0;
    static unsigned long file_lba = 0;
    
    static unsigned long target_bank_offset = 0;
    static unsigned long entry_point = 0;
    static unsigned char record_len = 0, record_type = 0;
    static unsigned short record_addr = 0;
    
    entry_point = 0;
    format_fat_name(filename, target_fat_name);

    for (s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) break;
        for (i = 0; i < 16; i++) {
            unsigned short off = i * 32;
            if (SDCARD_RAM_BUFFER[off] == 0x00) { s = g_root_sz_sects; break; }
            if (SDCARD_RAM_BUFFER[off] == 0xE5) continue;
            if (SDCARD_RAM_BUFFER[off + 11] & (0x08 | 0x10)) continue;

            found = 1;
            for (k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[off + k] != (unsigned char)target_fat_name[k]) {
                    found = 0; break;
                }
            }
            if (found) {
                start_cluster = (unsigned short)SDCARD_RAM_BUFFER[off + 26] | 
                               ((unsigned short)SDCARD_RAM_BUFFER[off + 27] << 8);
                file_size = *(unsigned long*)&SDCARD_RAM_BUFFER[off + 28];
                break;
            }
        }
        if (found) break;
    }

    if (!found) return 0;

    file_lba = g_data_lba_start + ((unsigned long)(start_cluster - 2) * (unsigned long)g_sectors_per_cluster);
    
    while (file_size > 0) {
        if (sdcard_read_sector(file_lba) != 0) break;
        
        const char *ptr = (const char *)SDCARD_RAM_BUFFER;
        unsigned short bytes_left = 512;

        while (bytes_left > 11) {
            // Find the start of the next record
            while (bytes_left > 0 && *ptr != ':') {
                ptr++;
                bytes_left--;
            }

            if (bytes_left <= 11) break; 

            // MARK START: Everything from here to the end of record must be tracked
            const char *record_base = ptr; 
            ptr++; // Skip ':'

            record_len  = get_hex_pair(&ptr);
            record_addr = (unsigned short)get_hex_pair(&ptr) << 8;
            record_addr |= (unsigned short)get_hex_pair(&ptr);
            record_type = get_hex_pair(&ptr);

            if (record_type == 0x00) { // Data Record
                unsigned long full_dest = target_bank_offset + (unsigned long)record_addr;
                
                for (k = 0; k < record_len; k++) {
                    unsigned char val = get_hex_pair(&ptr);
                    unsigned long current_ptr = full_dest + k;

                    // Snoop the Reset Vector to build the entry_point
                    if (current_ptr == 0x00FFFC) {
                        // Low byte
                        entry_point = (unsigned long)val;
                        // os_print_char('L');
                        // print_hex32(entry_point);
                    } 
                    else if (current_ptr == 0x00FFFD) {
                        // High byte
                        entry_point = entry_point | ((unsigned long)val << 8);
                        // os_puts("Reset vector jump to: ");
                        // print_hex32(entry_point);
                    }
                    else
                    {
                        *((unsigned char __far *)(current_ptr)) = val;
                    }
                }
                get_hex_pair(&ptr); // Checksum
            }
            else if (record_type == 0x04) { // Bank
                unsigned short bank = (unsigned short)get_hex_pair(&ptr) << 8;
                bank |= (unsigned short)get_hex_pair(&ptr);
                target_bank_offset = (unsigned long)bank << 16;
                get_hex_pair(&ptr); // Checksum
            }
            else if (record_type == 0x01) { // EOF
                return entry_point;
            }
            else {
                // Skip unknown
                for (k = 0; k < (record_len + 1); k++) get_hex_pair(&ptr);
            }

            // CRITICAL SYNC: Subtract exactly how many ASCII characters we moved
            unsigned short consumed = (unsigned short)(ptr - record_base);
            if (consumed >= bytes_left) bytes_left = 0;
            else bytes_left -= consumed;
        }

        file_lba++;
        if (file_size > 512) file_size -= 512; else file_size = 0;
    }
    return entry_point;
}


static void run_gfxTest(void) {
    unsigned long entry;

    os_puts("Loading GFX...");
    os_newline();

    entry = load_hex_from_sd("GFXTEST.HEX");

    os_newline();
    os_puts("Entry found at: ");
    print_hex32(entry);
    os_newline();

    // --- Memory Verification Start ---
    os_puts("Peeking at ");
    print_hex32(entry);
    os_puts(": ");
    // We use a far pointer to ensure we are looking at Bank 00
    unsigned char __far *peek = (unsigned char __far *)entry;

    for(char i = 0; i < 4; i++) {
        print_hex(peek[i]);
    }
    //os_puts(" >>> ");
    os_print_char(' ');
    
    unsigned char __far *peek_bank3 = (unsigned char __far *)0x030000;
    for(char j = 0; j < 4; j++) {
        print_hex(peek_bank3[j]);
        //os_print_char(' ');
    }
    os_newline();
    // --- Memory Verification End ---


    os_puts("C app...");
    os_newline();

    
    (*(volatile unsigned char __far*)0x000FEE) = (unsigned char)(entry & 0xFF);
    (*(volatile unsigned char __far*)0x000FEF) = (unsigned char)((entry >> 8) & 0xFF);
    (*(volatile unsigned char __far*)0x000FF0) = (unsigned char)((entry >> 16) & 0xFF);

    __asm(" jsl 0x00E000\n");

    os_puts(" ...back");
    os_newline();


}

void main(void)
{
    os_newline();

    os_puts("Attempting to read SD card... ");
    os_newline();
    fat16_test();
    os_puts("Finished SD card test!");
    os_newline();

    run_gfxTest();
    os_puts("Back to Shell main()");

    os_c_return();
}
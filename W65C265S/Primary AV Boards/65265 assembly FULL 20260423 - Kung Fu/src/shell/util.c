#include "util.h"
#include "os.h"

void delay(long counts) {
    volatile long i;
    volatile long j;

    for (i = 0; i < counts; i++) {
        for (j = 0; j < 100; j++) {
            // volatile ensures the compiler doesn't 
            // delete this "useless" loop.
        }
    }
}

void delayms(unsigned short ms) {
    volatile unsigned short i;
    volatile unsigned short j;

    for (i = 0; i < ms; i++) {
        for (j = 0; j < 588; j++) {
            // Approximately 1ms per 'i' iteration at 10MHz
        }
    }
}

void print_dec8(unsigned char val) {
    if (val >= 10) {
        os_print_char((val / 10) + '0');
    } else {
        os_print_char('0'); // Leading zero for consistent formatting
    }
    os_print_char((val % 10) + '0');
}

void print_dec8_serial(unsigned char val) {
    if (val >= 10) {
        os_print_char_serial((val / 10) + '0');
    } else {
        os_print_char('0'); // Leading zero for consistent formatting
    }
    os_print_char_serial((val % 10) + '0');
}

void print_dec_year(unsigned short val) {
    // Basic 4-digit printer
    os_print_char((val / 1000) + '0');
    os_print_char(((val / 100) % 10) + '0');
    os_print_char(((val / 10) % 10) + '0');
    os_print_char((val % 10) + '0');
}

void print_hex8(unsigned char val)
{
   
    unsigned char high = (val >> 4) & 0x0f;
    unsigned char low = val & 0x0f;
    
    os_print_char(hex_digits_far[high]);
    os_print_char(hex_digits_far[low]);
}

void print_hex8_serial(unsigned char val)
{
   
    unsigned char high = (val >> 4) & 0x0f;
    unsigned char low = val & 0x0f;
    
    os_print_char_serial(hex_digits_far[high]);
    os_print_char_serial(hex_digits_far[low]);
}

void print_hex16_serial(unsigned int value) {
    // Send the high byte (Bank/High)
    print_hex8_serial((unsigned char)(value >> 8));
    // Send the low byte
    print_hex8_serial((unsigned char)(value & 0x00FF));
}

void print_hex32(unsigned long val)
{
    for (int shift = 28; shift >= 0; shift -= 4) {
        unsigned char nib = (val >> shift) & 0x0F;
        os_print_char(hex_digits[nib]);
    }
}

void print_hex_serial(unsigned char val)
{
    // Force 24-bit addressing for the lookup table
    // This prevents reading 'garbage' from the code bank (Bank 01)
    
    unsigned char high = (val >> 4) & 0x0f;
    unsigned char low = val & 0x0f;
    
    os_print_char_serial(hex_digits_far[high]);
    os_print_char_serial(hex_digits_far[low]);
}

unsigned char bcd_to_bin(unsigned char bcd)
{
    // Convert BCD (e.g., 0x26) to standard Integer (26)
    return ((bcd >> 4) * 10) + (bcd & 0x0F);
}

unsigned char hex_to_byte(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    return 0;
}

unsigned long hex_to_long(char *str) {
    unsigned long res = 0;
    while (*str) {
        char c = *str++;
        if (c == ' ' || c == '\0') break;
        if (c == 'x' || c == 'X') continue; // Skip '0x' prefix if present
        
        res <<= 4;
        if (c >= '0' && c <= '9') res += (c - '0');
        else if (c >= 'a' && c <= 'f') res += (c - 'a' + 10);
        else if (c >= 'A' && c <= 'F') res += (c - 'A' + 10);
    }
    return res;
}

void print_dec32(unsigned long n) {
    char buffer[11]; // Max 4,294,967,295 plus null
    int i = 10;
    buffer[i--] = '\0';

    if (n == 0) {
        os_print_char('0');
        return;
    }

    while (n > 0) {
        buffer[i--] = (n % 10) + '0';
        n /= 10;
    }

    os_puts(&buffer[i + 1]);
}

void print_padded_dec32(unsigned long n) {
    char buffer[11];
    signed char i = 10;
    unsigned char count = 0;
    buffer[i--] = '\0';

    if (n == 0) {
        os_print_char('0');
        count = 1;
    } else {
        // Simple decimal conversion without heavy division
        while (n > 0) {
            buffer[i--] = (n % 10) + '0';
            n /= 10;
            count++;
        }
        os_puts(&buffer[i + 1]);
    }

    // Pad the rest of the 15-character column with spaces
    // This replaces the "leading zeros" with "trailing spaces"
    for (unsigned char s = count; s < 15; s++) {
        os_print_char(' ');
    }
}

unsigned char dec_to_bcd(unsigned char val) {
    unsigned char tens = 0;
    while (val >= 10) {
        val -= 10;
        tens++;
    }
    return (unsigned char)((tens << 4) | val);
}

void int_to_ascii(unsigned short val, char* buf) {
    int i = 0;
    // Handle the three digits for 0-999
    buf[0] = (val / 100) + '0';       // Hundreds
    buf[1] = ((val / 10) % 10) + '0'; // Tens
    buf[2] = (val % 10) + '0';        // Ones
    buf[3] = '\0';                    // Null terminate
}

void int_to_ascii_dec(unsigned short val, char* buf) {
    // Handle 0-9999
    buf[0] = (val / 1000) + '0';          // Thousands (2)
    buf[1] = ((val / 100) % 10) + '0';    // Hundreds  (0)
    buf[2] = ((val / 10) % 10) + '0';     // Tens      (0)
    buf[3] = (val % 10) + '0';            // Ones      (0)
    buf[4] = '\0';                        // Null terminate
}
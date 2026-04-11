#ifndef UTILS_H
#define UTILS_H

#include <calypsi/intrinsics65816.h>
#include "../include/calypsi_intellisense_fix.h"

const char __far hex_digits_far[] = "0123456789ABCDEF";
const char hex_digits[] = "0123456789ABCDEF";


void delay(long counts);
void delayms(unsigned short ms);
void print_dec8(unsigned char val);
void print_dec_year(unsigned short val);
void print_hex8(unsigned char val);
void print_hex32(unsigned long val);
void print_hex_serial(unsigned char val);
unsigned char bcd_to_bin(unsigned char bcd);
unsigned char hex_to_byte(char c);
unsigned long hex_to_long(char *str);
void print_dec32(unsigned long n);
void print_padded_dec32(unsigned long n);
unsigned char dec_to_bcd(unsigned char val);
void print_dec8_serial(unsigned char val);
void print_hex8_serial(unsigned char val);
void int_to_ascii(unsigned short val, char* buf);



#endif
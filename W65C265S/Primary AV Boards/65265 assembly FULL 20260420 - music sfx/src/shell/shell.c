#include "../include/calypsi_intellisense_fix.h"
#include <calypsi/intrinsics65816.h>
#include <string.h>
#include "graphics.h"
#include "util.h"
#include "os.h"
#include "filesys.h"

#define SHELL_VERSION "0.04"
#define MAX_ARGS 8

static char cmd_line[64];
static int idx = 0;

static void display_date_time(void) {
    unsigned short f_date, f_time;
    
    get_system_time_fat(&f_date, &f_time);

    // Unpacking logic remains correct
    unsigned short display_year = (f_date >> 9) + 1980;
    unsigned char display_month = (f_date >> 5) & 0x0F;
    unsigned char display_day   = f_date & 0x1F;
    
    unsigned char display_hour = (f_time >> 11) & 0x1F;
    unsigned char display_min  = (f_time >> 5) & 0x3F;
    unsigned char display_sec  = (f_time & 0x1F) * 2;

    os_puts("Current Date/Time: ");
    
    // Switch from hex to decimal printers
    print_dec8(display_month);
    os_print_char('/');
    print_dec8(display_day);
    os_print_char('/');
    print_dec_year(display_year);
    
    os_puts(" ");
    
    print_dec8(display_hour);
    os_print_char(':');
    print_dec8(display_min);
    os_print_char(':');
    print_dec8(display_sec);
    
    os_newline();
}

typedef void (*command_func_t)(char *args);
typedef struct {
    const char *name;
    command_func_t func;
} shell_command_t;

// Forward declarations with updated signatures
static void cmd_help(char *args);
static void cmd_cls(char *args);
static void cmd_ver(char *args);
static void cmd_dir(char *args);
static void cmd_exit(char *args);
static void cmd_type(char *args);
static void cmd_run_hex(char *args);
static void cmd_memdump_serial(char *args);
static void cmd_load_hex(char *args);
static void cmd_datetime(char *args);
static void cmd_gfxTest(char *args);
static void cmd_del(char *args);
static void cmd_copy(char *args);
static void cmd_ren(char *args);
static void cmd_setdatetime(char *args);
static void cmd_run_bin(char *args);
static void cmd_win(char *args);
static void cmd_shooter(char *args);
static void cmd_play_music(char *args);
static void cmd_play_sfx(char *args);
static void cmd_shooter2(char *args);

// Shell command jump table
const shell_command_t command_table[] = {
    {"help", cmd_help},
    {"?",    cmd_help},
    {"cls",  cmd_cls},
    {"ver",  cmd_ver},
    {"dir",  cmd_dir},
    {"exit", cmd_exit},
    {"type", cmd_type},
    {"runhex", cmd_run_hex},
    {"memdump", cmd_memdump_serial},
    {"load", cmd_load_hex},
    {"datetime", cmd_datetime},
    {"gfxTest", cmd_gfxTest},
    {"del", cmd_del},
    {"copy", cmd_copy},
    {"ren", cmd_ren},
    {"set-datetime", cmd_setdatetime},
    {"runbin", cmd_run_bin},
    {"win", cmd_win},
    {"shooter", cmd_shooter},
    {"playmusic", cmd_play_music},
    {"playsfx", cmd_play_sfx},
    {"shooter2", cmd_shooter2},
    {NULL,   NULL}
};

static void cmd_help(char *args) {
    os_puts("Available: help (?), cls, ver, dir, del, copy, ren,\n exit, type, runhex, memdump, load, datetime,\n gfxTest, set-datetime, runbin,\n win, shooter, playmusic, playsfx, shooter2");
    os_newline_with_prompt();
}

static void cmd_cls(char *args) {
    os_clear_screen();
    os_print_char('$');
}

static void cmd_ver(char *args) {
    os_puts("R265Nibbler Shell version ");
    os_puts(SHELL_VERSION);
    os_newline_with_prompt();
}

static void cmd_dir(char *args) {
    if (fat_init() == 0) {
        list_root_directory();
    } else {
        os_puts("FAT16 Init Failed!");
    }  
    os_newline_with_prompt();
}

static void cmd_exit(char *args) {
    os_puts("Exiting shell...");
    os_c_return(); 
}

static void cmd_type(char *args) {
    // Check if at least one argument (the filename) was provided
    if (args == NULL || args[0] == '\0') {
        os_puts("Usage: type <filename>");
        os_newline();
        return;
    }

    print_file_contents(args);

    os_newline_with_prompt();
}

static void cmd_memdump_serial(char *args) 
{
    // 1. Skip leading spaces
    while (*args == ' ') args++;

    // 2. Check for first parameter (address) - Output help to VGA
    if (*args == '\0') {
        os_newline();
        os_puts("Usage: memdump [addr_hex] [bytes_hex]");
        os_newline();
        os_puts("Example: memdump 0x005000 0x80");
        os_newline_with_prompt();
        return;
    }

    unsigned long start_addr = hex_to_long(args);

    // 3. Move to the next argument
    while (*args != ' ' && *args != '\0') args++; 
    while (*args == ' ') args++;                  

    // 4. Check for second parameter (count) - Output error to VGA
    if (*args == '\0') {
        os_newline();
        os_puts("Error: Missing byte count.");
        os_newline();
        os_puts("Usage: memdump [addr_hex] [bytes_hex]");
        os_newline_with_prompt();
        return;
    }

    unsigned int num_bytes = (unsigned int)hex_to_long(args);

    // 5. Execute the dump to Serial
    unsigned char __far *ptr = (unsigned char __far *)start_addr;

    os_newline_serial();
    for (unsigned int i = 0; i < num_bytes; i++) {
        if (i % 16 == 0) {
            if (i > 0) os_newline_serial();
            
            unsigned long current_row_addr = start_addr + i;
            
            // Print the 32-bit address label to Serial
            print_hex_serial((unsigned char)(current_row_addr >> 24));
            print_hex_serial((unsigned char)(current_row_addr >> 16));
            print_hex_serial((unsigned char)(current_row_addr >> 8));
            print_hex_serial((unsigned char)(current_row_addr));
            
            os_print_char_serial(':');
            os_print_char_serial(' ');
        }

        // Print memory content to Serial
        print_hex_serial(ptr[i]);
        os_print_char_serial(' ');
    }
    
    os_newline_serial();
    os_newline_with_prompt();
}

static void cmd_run_hex(char *args) {

    // Check if at least one argument (the filename) was provided
    if (args == NULL || args[0] == '\0') {
        os_puts("Usage: run <filename>");
        os_newline();
        return;
    }

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    os_newline();
    os_puts("Loading and executing: ");
    os_puts(args);
    os_newline();

    unsigned long entry = load_hex_from_sd(args);     // < this line causes issues **

    (*(volatile unsigned char __far*)0x000FEE) = (unsigned char)(entry & 0xFF);
    (*(volatile unsigned char __far*)0x000FEF) = (unsigned char)((entry >> 8) & 0xFF);
    //(*(volatile unsigned char __far*)0x000FF0) = (unsigned char)((entry >> 16) & 0xFF);   //not needed, as always should be 0x00

    os_newline();
    os_puts("Jumping to 0x");
    print_hex32(entry);          
    os_newline();

    __asm(" jsl 0x00E000\n");

    os_newline();
    os_puts("Back to Shell...");
    os_newline();

}

static void cmd_load_hex(char *args) {

    // Check if at least one argument (the filename) was provided
    if (args == NULL || args[0] == '\0') {
        os_puts("Usage: run <filename>");
        os_newline();
        return;
    }

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    os_newline();
    os_puts("Loading: ");
    os_puts(args);
    os_newline();

    unsigned long entry = load_hex_from_sd(args);     // < this line causes issues **

    (*(volatile unsigned char __far*)0x000FEE) = (unsigned char)(entry & 0xFF);
    (*(volatile unsigned char __far*)0x000FEF) = (unsigned char)((entry >> 8) & 0xFF);
    //(*(volatile unsigned char __far*)0x000FF0) = (unsigned char)((entry >> 16) & 0xFF);   //not needed, as always should be 0x00

    os_newline();
    os_puts("Jump address of 0x");
    print_hex32(entry);          
    os_newline();

    os_newline_with_prompt();
}

static void cmd_datetime(char *args) {
    display_date_time();
    os_newline_with_prompt();
}

static void cmd_gfxTest(char *args) {
    graphics_test();
    os_clear_screen();
    os_print_char('$');
}

static void cmd_del(char *args) {
    if (args == NULL || args[0] == '\0') {
        os_puts("Usage: del <filename>");
        os_newline();
        return;
    }

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    os_newline();
    os_puts("Deleting: ");
    os_puts(args);
    os_newline();

    signed char result = delete_file(args);
    
    if (result == 0) {
        os_puts("File deleted successfully.");
    } else if (result == -1) {
        os_puts("Error: File not found.");
    } else if (result == -2) {
        os_puts("Error: Could not update FAT.");
    } else {
        os_puts("Unknown error during deletion.");
    }

    os_newline_with_prompt();
}

static void cmd_copy(char *args) {
    char *src = strtok(args, " ");
    char *dst = strtok(NULL, " ");

    if (src == NULL || dst == NULL) {
        os_puts("Usage: copy <src> <dst>");
        os_newline_with_prompt();
        return;
    }

    signed char result = copy_file(src, dst);
    if (result == 0) {
        os_puts("File copied.");
    } else {
        os_puts("Error: ");
        print_hex8((unsigned char)result);
    }
    os_newline_with_prompt();
}

static void cmd_ren(char *args) {
    char *old_name = strtok(args, " ");
    char *new_name = strtok(NULL, " ");

    if (old_name == NULL || new_name == NULL) {
        os_puts("Usage: ren <old> <new>");
        os_newline_with_prompt();
        return;
    }

    signed char result = rename_file(old_name, new_name);
    if (result == 0) {
        os_puts("File renamed.");
    } else {
        os_puts("Error: ");
        print_hex8((unsigned char)result);
    }
    os_newline_with_prompt();
}

static void cmd_setdatetime(char *args) {
    /* Expected format: set-datetime YY MM DD HH MM SS */
    unsigned char values[6];
    char *ptr = args;
    unsigned char count = 0;
    unsigned char current_val;

    while (count < 6) {
        // 1. Skip anything that isn't a digit (spaces, tabs, etc.)
        while (*ptr != '\0' && (*ptr < '0' || *ptr > '9')) {
            ptr++;
        }

        // 2. If we hit the end of the string before 6 numbers, stop
        if (*ptr == '\0') break;

        // 3. Manual A-to-I: Convert digits to a number
        current_val = 0;
        while (*ptr >= '0' && *ptr <= '9') {
            current_val = (current_val * 10) + (*ptr - '0');
            ptr++;
        }
        
        values[count++] = (unsigned char)current_val;
    }

    // Check if we actually got 6 segments
    if (count < 6) {
        os_puts("Usage: set-datetime YY MM DD HH MM SS");
        os_newline_with_prompt();
        return;
    }

    SYSCALL_PARAMS.param0 = (unsigned char)(dec_to_bcd(values[0]) & 0xFF); // Year
    SYSCALL_PARAMS.param1 = (unsigned char)(dec_to_bcd(values[1]) & 0xFF); // Month
    SYSCALL_PARAMS.param2 = (unsigned char)(dec_to_bcd(values[2]) & 0xFF); // Day
    SYSCALL_PARAMS.param3 = (unsigned char)(dec_to_bcd(values[3]) & 0xFF); // Hour
    SYSCALL_PARAMS.param4 = (unsigned char)(dec_to_bcd(values[4]) & 0xFF); // Minute
    SYSCALL_PARAMS.param5 = (unsigned char)(dec_to_bcd(values[5]) & 0xFF); // Second

    // Trigger the Syscall ($15 = 21 decimal)
    __asm(" cop #0x15\n");

    os_puts("RTC Updated.");
    os_newline_with_prompt();
}

static void cmd_run_bin(char *args) {
    if (args == NULL || args[0] == '\0') {
        os_puts("Usage: run <filename>");
        os_newline();
        return;
    }

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    os_puts("Loading: ");
    os_puts(args);
    os_newline();

    // Load to 0x03:0000
    signed char result = load_bin_from_sd(args, 0x030000L);

    if (result == 0) {
        os_puts("Jumping to 03:0000...");
        os_newline();

        // Perform the jump
        __asm(" jsl 0x030000\n");

        os_newline();
        os_puts("Back to Shell...");
    } else {
        os_puts("Error loading file: ");
        print_hex8((unsigned char)result);
    }
    os_newline_with_prompt();
}

static void cmd_win(char *args) {
    start_windows();
    os_clear_screen();
    os_print_char('$');
}

static void cmd_shooter(char *args) {
    start_shooter();
    os_clear_screen();
    os_print_char('$');
}

static void cmd_play_music(char *args) {
    char *music_id_str = strtok(args, " ");
    char *volume_str = strtok(NULL, " ");
    char *loop_str = strtok(NULL, " ");

    // if (music_id_str == NULL || volume_str == NULL || loop_str == NULL) {
    if (music_id_str == NULL) {
        //os_puts("Usage: playmusic <music_id> <volume> <loop_flag>");
        os_puts("Usage: playmusic <music_id (in hex)>");
        os_newline_with_prompt();
        return;
    }

    unsigned short music_id = (unsigned short)hex_to_long(music_id_str);
    // unsigned short volume = (unsigned short)hex_to_long(volume_str);
    // unsigned char loop_flag = (unsigned char)hex_to_long(loop_str);

    // os_play_music(music_id, volume, loop_flag);
    os_play_music(music_id);

    os_puts("Music command sent (music id: ");
    print_dec8(music_id);
    os_puts(")");
    os_newline_with_prompt();
}

static void cmd_play_sfx(char *args) {
    char *sfx_id_str = strtok(args, " ");
    char *volume_str = strtok(NULL, " ");
    char *loop_str = strtok(NULL, " ");

    if (sfx_id_str == NULL) {
        //os_puts("Usage: playmusic <music_id> <volume> <loop_flag>");
        os_puts("Usage: playsfx <sfx_id (in hex)>");
        os_newline_with_prompt();
        return;
    }

    unsigned short sfx_id = (unsigned short)hex_to_long(sfx_id_str);

    os_play_sfx(sfx_id);

    os_puts("SFX command sent (sfx id: ");
    print_dec8(sfx_id);
    os_puts(")");
    os_newline_with_prompt();
}

static void cmd_shooter2(char *args) {
    start_shooter2();
    os_clear_screen();
    os_print_char('$');
}


void p64_toggle(void) {
    PD6 ^= 0x10; // XOR with 0001 0000 to toggle bit 4
}

void execute_command(char *cmd) {
    char *args = NULL;
    int i = 0;

    // 1. Find the first space to separate command from arguments
    for (i = 0; cmd[i] != '\0'; i++) {
        if (cmd[i] == ' ') {
            cmd[i] = '\0';      // Terminate command name here
            args = &cmd[i + 1]; // Arguments start after the space
            break;
        }
    }

    // 2. Search jump table
    for (i = 0; command_table[i].name != NULL; i++) {
        if (strcmp(cmd, command_table[i].name) == 0) {
            // Pass the pointer to the arguments (or NULL if none)
            command_table[i].func(args);
            return;
        }
    }

    os_puts("Unknown command.");
    os_newline_with_prompt();
}

static void keyboard_check()
{
    char c;

    c = os_kbd_get_char();

    if (c != 0) {
        if (c == 0x0D) { // ENTER
            cmd_line[idx] = '\0'; // Null terminate
            os_newline();
            
            if (idx > 0) {
                execute_command(cmd_line);
            }
            else {
                //just an enter key
                os_print_char('$');
            }
            idx = 0; // Reset for next command

                
            // This loop clears the buffer of any immediate repeats -- this really shouldn't be necessary! *bug
            while(os_kbd_get_char() != 0) {};

        } 
        else if (c == 0x08 || c == 0x7F) { // Backspace
            if (idx > 0) {
                idx--;
                // Optional: Handle visual backspace if supported
                os_print_char('{'); 
            }
        }
        else if (c >= 0x20 && c <= 0x7E) {
            // Echo the character and store it
            os_print_char(c);
            cmd_line[idx++] = c;
        }
    }
}

void main(void)
{
    if (fat_init() != 0) {
        os_puts("FAT16 Init Failed!");
        os_newline();
    }  

    os_newline();
    os_puts("Welcome to the R265Nibbler Shell version ");
    os_puts(SHELL_VERSION);
    os_print_char('!');
    os_newline();
    display_date_time();
    
    
    os_newline_serial();
    os_puts_serial("Shell loaded");
    os_newline_serial();

    os_print_char('$');

    while(1) {
        keyboard_check();
        
        p64_toggle(); // Visual heartbeat

        // Other background tasks here
    }
}
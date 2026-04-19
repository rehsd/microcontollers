#include <calypsi/intrinsics65816.h>
#include "../include/calypsi_intellisense_fix.h"

#include "filesys.h"
#include "os.h"
#include "util.h"

// Define a safe area for the copy buffer (outside of stack/zero page)
#define COPY_TEMP_BUFFER ((unsigned char*)0x1500) 

unsigned char g_fat_initialized = 0;
char target_fat_name[16]; 


unsigned char sdcard_init()
{
    __asm(" cop #13\n");   // COP #13 ($0D)
    return SYSCALL_PARAMS_RESULT;
}

int sdcard_read_sector(unsigned long block_num)
{
    // buffer to store 512 bytes of data read from the SD card block: SDCARD_RAM_BUFFER
    //SYSCALL_PARAMS_START = block_num;
    (*(volatile unsigned long*)0x0F00) = block_num;
    __asm(" cop #11\n");   // COP #11 ($0B)
    // SDCARD_RAM_BUFFER now has 512 bytes of data from the SD card block specified by block_num
    return SYSCALL_PARAMS_RESULT;
}

int sdcard_write_sector(unsigned long block_num)
{
    // buffer to read from RAM and write the SD card block: SDCARD_RAM_BUFFER
    //SYSCALL_PARAMS_START = block_num;
    (*(volatile unsigned long*)0x0F00) = block_num;
    __asm(" cop #12\n");   // COP #12 ($0C)
    return SYSCALL_PARAMS_RESULT;
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
    // fat_debug_print();

    return 0;
}

void list_root_directory()
{
    /*
     * Iterates through the root directory and displays entries.
     * Includes Timestamps, File Size (Decimal), and Type.
     */   

    if (!g_fat_initialized) {
        os_puts("FS not init.");
        os_newline();
        return;
    }

    // --- PASS 1: Search specifically for the Volume Label to display it first ---
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) break;

        DirectoryEntry_t *entries = (DirectoryEntry_t*)SDCARD_RAM_BUFFER;
        for (char i = 0; i < 16; i++) {
            unsigned char first_char = entries[i].filename[0];
            unsigned char attr = entries[i].attributes;

            if (first_char == 0x00) break; 
            if (first_char == (unsigned char)0xE5) continue;

            if ((attr & 0x08) && !(attr & 0x10) && (attr != 0x0F)) {
                os_puts("<VOL> ");
                for (char j = 0; j < 11; j++) {
                    char c = ((char*)entries[i].filename)[j];
                    if (c != 0) os_print_char(c); 
                }
                os_newline();
                s = g_root_sz_sects; 
                break; 
            }
        }
    }

    // --- PASS 2: Display Directories and Files with Timestamps and Sizes ---
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) {
            os_puts("Dir Read Error");
            os_newline();
            break;
        }

        DirectoryEntry_t *entries = (DirectoryEntry_t*)SDCARD_RAM_BUFFER;

        for (char i = 0; i < 16; i++) {
            unsigned char first_char = entries[i].filename[0];
            unsigned char attr = entries[i].attributes;

            if (first_char == 0x00) return;
            if (first_char == (unsigned char)0xE5) continue;
            if (attr == 0x0F) continue; 
            if ((attr & 0x08) && !(attr & 0x10)) continue;

            // Unpack Date
            unsigned short d = entries[i].write_date;
            unsigned short year = (d >> 9) + 1980;
            unsigned char month = (d >> 5) & 0x0F;
            unsigned char day   = d & 0x1F;

            // Unpack Time
            unsigned short t = entries[i].write_time;
            unsigned char hour = (t >> 11) & 0x1F;
            unsigned char min  = (t >> 5) & 0x3F;

            // Print Timestamp (MM/DD/YYYY HH:MM)
            print_dec8(month);
            os_print_char('/');
            print_dec8(day);
            os_print_char('/');
            print_dec_year(year);
            os_puts("  ");
            print_dec8(hour);
            os_print_char(':');
            print_dec8(min);
            os_puts("  ");

            // --- Handle Type and File Size (Decimal with Fixed 15-character Column) ---
            if (attr & 0x10) { 
                // Pad to match the 15-character width used by the file size printer
                os_puts("<DIR>          "); 
            } else {
                // Fetch the 32-bit size manually from offset 28
                unsigned char *p = (unsigned char*)&entries[i];
                unsigned long actual_size = (unsigned long)p[28] | 
                                           ((unsigned long)p[29] << 8) | 
                                           ((unsigned long)p[30] << 16) | 
                                           ((unsigned long)p[31] << 24);
                
                // This routine must print the number and then pad with spaces to 15 chars
                print_padded_dec32(actual_size); 
            }

            // Print Filename (Starts at column 16)
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

void copy_bytes(unsigned char* dst, const unsigned char* src, unsigned short count)
{
    while (count--) {
        *dst++ = *src++;
    }
}

void clear_bytes(unsigned char* dst, unsigned short count)
{
    while (count--) {
        *dst++ = 0;
    }
}

void copy512(unsigned char* dst, const unsigned char* src)
{
    for (unsigned short i = 0; i < 512; i++) {
        dst[i] = src[i];
    }
}

signed char allocate_cluster(unsigned short* out_cluster)
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
        print_hex8(result);
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
            print_hex8(SDCARD_RAM_BUFFER[i]);
            os_print_char(' ');
        }
        os_newline();
    } else {
        os_puts("Sector read failed with error code: ");
        print_hex8(result);
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
        print_hex8(result);
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
            print_hex8(SDCARD_RAM_BUFFER[i]);
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
            print_hex8(result);
        }
        os_newline();
    } else {
        os_puts("FAT16 Init Failed.");
        os_newline();
    }  

}

unsigned long load_hex_from_sd(const char* filename) {
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

void get_system_time_fat(unsigned short* fat_date, unsigned short* fat_time) {
    __asm(" cop #14\n"); 

    // Force pointer to unsigned char to ensure 8-bit access
    volatile unsigned char *p = (volatile unsigned char *)0x0F00;

    unsigned char year  = bcd_to_bin(p[0]); 
    unsigned char month = bcd_to_bin(p[1]);
    unsigned char day   = bcd_to_bin(p[2]);
    unsigned char hour  = bcd_to_bin(p[3]);
    unsigned char min   = bcd_to_bin(p[4]);
    unsigned char sec   = bcd_to_bin(p[5]);

    // Mask month again here just in case assembly didn't catch it
    month &= 0x1F; 

    *fat_date = ((unsigned short)(year + 20) << 9) | 
                ((unsigned short)month << 5) | 
                (unsigned short)day;

    *fat_time = ((unsigned short)hour << 11) | 
                ((unsigned short)min << 5) | 
                (unsigned short)(sec / 2);
}

unsigned char get_hex_pair(const char **ptr) {
    unsigned char val = (hex_to_byte(**ptr) << 4);
    (*ptr)++;
    val |= hex_to_byte(**ptr);
    (*ptr)++;
    return val;
}

signed char create_directory_entry(const char* filename, unsigned short start_cluster, unsigned long file_size)
{
    char fat_name[12]; 
    format_fat_name(filename, fat_name);

    // 1. Find a free root directory entry slot
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

    // 2. Commit the directory entry
    if (sdcard_read_sector(target_lba) != 0) return -6;

    unsigned short entry_off = target_idx * 32;

    // Zero out the 32-byte slot
    for (char j = 0; j < 32; j++) SDCARD_RAM_BUFFER[entry_off + j] = 0;

    // Name and Extension
    for (char j = 0; j < 11; j++) SDCARD_RAM_BUFFER[entry_off + j] = (unsigned char)fat_name[j];

    SDCARD_RAM_BUFFER[entry_off + 11] = 0x20; // Archive attribute

    unsigned short f_date, f_time;
    get_system_time_fat(&f_date, &f_time);

    // Timestamps
    SDCARD_RAM_BUFFER[entry_off + 22] = (unsigned char)(f_time & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 23] = (unsigned char)(f_time >> 8);
    SDCARD_RAM_BUFFER[entry_off + 24] = (unsigned char)(f_date & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 25] = (unsigned char)(f_date >> 8);

    // Start Cluster
    SDCARD_RAM_BUFFER[entry_off + 26] = (unsigned char)(start_cluster & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 27] = (unsigned char)(start_cluster >> 8);

    // File Size
    SDCARD_RAM_BUFFER[entry_off + 28] = (unsigned char)(file_size & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 29] = (unsigned char)((file_size >> 8) & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 30] = (unsigned char)((file_size >> 16) & 0xFF);
    SDCARD_RAM_BUFFER[entry_off + 31] = (unsigned char)((file_size >> 24) & 0xFF);

    if (sdcard_write_sector(target_lba) != 0) return -7;

    return 0;
}

signed char rename_file(const char* old_filename, const char* new_filename)
{
    if (!g_fat_initialized) return -1;

    char old_fat_name[12];
    char new_fat_name[12];
    unsigned char found = 0;

    format_fat_name(old_filename, old_fat_name);
    format_fat_name(new_filename, new_fat_name);

    // 1. Optional: Check if the NEW filename already exists
    // If it exists, we should probably fail to prevent duplicates
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) break;
        for (char i = 0; i < 16; i++) {
            unsigned short off = i * 32;
            if (SDCARD_RAM_BUFFER[off] == 0x00) break; 
            if (SDCARD_RAM_BUFFER[off] == 0xE5) continue;

            unsigned char match = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[off + k] != (unsigned char)new_fat_name[k]) {
                    match = 0;
                    break;
                }
            }
            if (match) return -2; // Error: New filename already exists
        }
    }

    // 2. Find the OLD filename and update it
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        unsigned long dir_lba = g_root_lba_start + s;
        if (sdcard_read_sector(dir_lba) != 0) break;

        for (char i = 0; i < 16; i++) {
            unsigned short off = i * 32;
            if (SDCARD_RAM_BUFFER[off] == 0x00) { s = g_root_sz_sects; break; }
            if (SDCARD_RAM_BUFFER[off] == 0xE5) continue;

            unsigned char match = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[off + k] != (unsigned char)old_fat_name[k]) {
                    match = 0;
                    break;
                }
            }

            if (match) {
                // Update the name (8 bytes) and extension (3 bytes)
                for (char k = 0; k < 11; k++) {
                    SDCARD_RAM_BUFFER[off + k] = (unsigned char)new_fat_name[k];
                }

                // Update the last modified time/date while we are here
                unsigned short f_date, f_time;
                get_system_time_fat(&f_date, &f_time);
                
                SDCARD_RAM_BUFFER[off + 22] = (unsigned char)(f_time & 0xFF);
                SDCARD_RAM_BUFFER[off + 23] = (unsigned char)(f_time >> 8);
                SDCARD_RAM_BUFFER[off + 24] = (unsigned char)(f_date & 0xFF);
                SDCARD_RAM_BUFFER[off + 25] = (unsigned char)(f_date >> 8);

                // Write the sector back to SD
                if (sdcard_write_sector(dir_lba) != 0) return -3;
                
                return 0; // Success
            }
        }
    }

    return -4; // Error: Old file not found
}

signed char copy_file(const char* src_filename, const char* dst_filename)
{
    if (!g_fat_initialized) return -1;

    char src_fat_name[12];
    unsigned short src_cluster = 0;
    unsigned short dst_cluster = 0;
    unsigned short prev_dst_cluster = 0;
    unsigned short first_dst_cluster = 0;
    unsigned long  file_size = 0;
    unsigned char  found = 0;

    format_fat_name(src_filename, src_fat_name);

    // 1. Locate Source
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) break;
        for (char i = 0; i < 16; i++) {
            unsigned short off = i * 32;
            if (SDCARD_RAM_BUFFER[off] == 0x00) { s = g_root_sz_sects; break; }
            if (SDCARD_RAM_BUFFER[off] == 0xE5) continue;
            
            unsigned char match = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[off + k] != (unsigned char)src_fat_name[k]) {
                    match = 0; break;
                }
            }
            if (match) {
                src_cluster = rd16(off + 26);
                file_size = rd32(off + 28);
                found = 1; break;
            }
        }
        if (found) break;
    }

    if (!found) return -2;

    delete_file(dst_filename);

    // 2. Loop through clusters
    unsigned long bytes_copied = 0;

    // Use bytes_copied as a safety guard against the 2MB "runaway" loop
    while (src_cluster >= 2 && src_cluster < 0xFFF8 && bytes_copied < file_size) {
        
        // A. Read Source Data
        unsigned long src_lba = g_data_lba_start + ((unsigned long)(src_cluster - 2) * g_sectors_per_cluster);
        if (sdcard_read_sector(src_lba) != 0) return -3;

        // B. Save to safe buffer
        copy512(COPY_TEMP_BUFFER, (const unsigned char*)SDCARD_RAM_BUFFER);

        // C. Fetch the NEXT source cluster BEFORE we modify the FAT
        // This is the "Magic Fix": Get the next link while the FAT is clean
        unsigned short src_fat_sec = src_cluster / 256;
        unsigned short src_fat_off = (src_cluster % 256) * 2;
        unsigned long s_fat_lba = g_partition_lba_start + g_rsvd_sec_cnt + src_fat_sec;
        
        if (sdcard_read_sector(s_fat_lba) != 0) return -6;
        unsigned short next_src_cluster = rd16(src_fat_off);

        // D. Allocate Destination
        if (allocate_cluster(&dst_cluster) != 0) return -4;
        if (first_dst_cluster == 0) first_dst_cluster = dst_cluster;

        // E. Link Chain in FAT
        if (prev_dst_cluster != 0) {
            unsigned short fat_sec = prev_dst_cluster / 256;
            unsigned short fat_off = (prev_dst_cluster % 256) * 2;
            unsigned long fat_lba = g_partition_lba_start + g_rsvd_sec_cnt + fat_sec;
            
            sdcard_read_sector(fat_lba);
            SDCARD_RAM_BUFFER[fat_off] = (unsigned char)(dst_cluster & 0xFF);
            SDCARD_RAM_BUFFER[fat_off + 1] = (unsigned char)(dst_cluster >> 8);
            sdcard_write_sector(fat_lba); 
            sdcard_write_sector(fat_lba + g_fat_size_sectors); 
        }

        // F. Write Destination Data
        copy512((unsigned char*)SDCARD_RAM_BUFFER, COPY_TEMP_BUFFER);
        unsigned long dst_lba = g_data_lba_start + ((unsigned long)(dst_cluster - 2) * g_sectors_per_cluster);
        if (sdcard_write_sector(dst_lba) != 0) return -5;

        // G. Update tracking
        bytes_copied += (512 * g_sectors_per_cluster);
        prev_dst_cluster = dst_cluster;
        src_cluster = next_src_cluster; // Move to the pre-fetched cluster
    }

    // 3. Finalize entry
    return create_directory_entry(dst_filename, first_dst_cluster, file_size);
}

signed char load_bin_from_sd(const char* filename, unsigned long dest_full_addr) {
    unsigned short start_cluster = 0;
    unsigned long file_size = 0;
    unsigned char found = 0;
    char target_name[12];
    
    format_fat_name(filename, target_name);

    // 1. Search Root Directory
    for (unsigned short s = 0; s < g_root_sz_sects; s++) {
        if (sdcard_read_sector(g_root_lba_start + s) != 0) return -1;
        
        for (char i = 0; i < 16; i++) {
            unsigned short off = i * 32;
            if (SDCARD_RAM_BUFFER[off] == 0x00) { s = g_root_sz_sects; break; }
            if (SDCARD_RAM_BUFFER[off] == 0xE5) continue;
            if (SDCARD_RAM_BUFFER[off + 11] & (0x08 | 0x10)) continue;

            found = 1;
            for (char k = 0; k < 11; k++) {
                if (SDCARD_RAM_BUFFER[off + k] != (unsigned char)target_name[k]) {
                    found = 0; break;
                }
            }

            if (found) {
                start_cluster = (unsigned short)SDCARD_RAM_BUFFER[off + 26] | 
                               ((unsigned short)SDCARD_RAM_BUFFER[off + 27] << 8);
                // Extract 32-bit file size
                file_size = *(unsigned long*)&SDCARD_RAM_BUFFER[off + 28];
                break;
            }
        }
        if (found) break;
    }

    if (!found) return -2;

    // 2. Load the file data
    unsigned long current_lba = g_data_lba_start + 
                                ((unsigned long)(start_cluster - 2) * (unsigned long)g_sectors_per_cluster);
    
    volatile unsigned char __far *dest_ptr = (volatile unsigned char __far *)dest_full_addr;

    while (file_size > 0) {
        if (sdcard_read_sector(current_lba) != 0) return -3;

        unsigned int to_copy = (file_size > 512) ? 512 : (unsigned int)file_size;
        
        // Copy directly from the SD RAM buffer to the __far target memory
        for (unsigned int j = 0; j < to_copy; j++) {
            *dest_ptr = SDCARD_RAM_BUFFER[j];
            dest_ptr++;
        }

        if (file_size > 512) file_size -= 512; else file_size = 0;
        current_lba++;
        
        //os_print_char('.'); // Progress indicator
    }

    //os_newline();
    return 0; // Success
}
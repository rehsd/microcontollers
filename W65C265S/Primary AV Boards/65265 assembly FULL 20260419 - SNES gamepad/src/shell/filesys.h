#ifndef FILESYS_H
#define FILESYS_H
#define SDCARD_RAM_BUFFER ((volatile unsigned char*)0x1200)

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
    unsigned char  EA_Index[2];      // Changed from short to char array
    unsigned short write_time;
    unsigned short write_date;
    unsigned short start_cluster;
    unsigned long  file_size;
} DirectoryEntry_t;

typedef struct {
    char filename[11];      // 8.3 filename (usually 11 bytes)
    unsigned char attr;     // File attributes (Read-only, Hidden, etc.)
    unsigned int start_cluster; // The first cluster of the file
    unsigned int curr_cluster;  // The cluster currently being read
    unsigned long size;     // Total file size in bytes
    unsigned long offset;   // Current byte position in the file
} fat_file_t;
#pragma pack(pop)

#define ATTR_READ_ONLY 0x01
#define ATTR_HIDDEN    0x02
#define ATTR_SYSTEM    0x04
#define ATTR_VOLUME_ID 0x08
#define ATTR_DIRECTORY 0x10
#define ATTR_ARCHIVE   0x20
#define ATTR_LONG_NAME 0x0F

// Global FAT16 state
extern unsigned char  g_fat_initialized;
unsigned short g_fat_size;  // Sectors per FAT
unsigned long  g_partition_lba_start;
unsigned short g_rsvd_sec_cnt;      // BPB_RsvdSecCnt
unsigned short g_fat_size_sectors;  // BPB_FATSz16
unsigned char  g_num_fats;          // BPB_NumFATs
unsigned short g_root_entries;      // BPB_RootEntCnt
unsigned long  g_root_lba_start;
unsigned short g_root_sz_sects;
unsigned long  g_data_lba_start;
unsigned char  g_sectors_per_cluster;


unsigned char sdcard_init();
int sdcard_read_sector(unsigned long block_num);
int sdcard_write_sector(unsigned long block_num);
void fat_debug_print();
void format_fat_name(const char* input, char* output);
unsigned short rd16(int off);
unsigned long rd32(int off);
unsigned char fat_init(void);
void list_root_directory();
void print_file_contents(const char* filename_with_ext);
signed char delete_file(const char* filename);
void copy_bytes(unsigned char* dst, const unsigned char* src, unsigned short count);
void clear_bytes(unsigned char* dst, unsigned short count);
void copy512(unsigned char* dst, const unsigned char* src);
signed char allocate_cluster(unsigned short* out_cluster);
signed char create_file(const char* filename, const char* content);
void fat16_test();
unsigned long load_hex_from_sd(const char* filename);
void get_system_time_fat(unsigned short* fat_date, unsigned short* fat_time);
unsigned char get_hex_pair(const char **ptr);
signed char copy_file(const char* src_filename, const char* dst_filename);
signed char rename_file(const char* old_filename, const char* new_filename);
signed char load_bin_from_sd(const char* filename, unsigned long dest_full_addr);

#endif
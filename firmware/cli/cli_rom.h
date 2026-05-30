#ifndef _CLI_RECORD_H_
#define _CLI_RECORD_H_

#include <inttypes.h>

typedef struct __attribute__((packed))
{

  // command description -- command key is ascii
  // value and index into this record table
  union {
    uint8_t command_key;
    char command_str[16];
  };

  uint16_t default_idx;
  uint16_t start_idx;
  uint16_t value_idx;
  uint16_t num_values;
  
} CliRecord_st;



typedef struct __attribute__((packed))
{
  CliRecord_st records[0x80];  // ascii 0x20 to 0x7f ; 0x0-0x1f reserved
  char banner[2048];
  uint32_t banner_len;
  union {
    char formatted_value[8];
    uint64_t long_value;
    uint32_t int_value;
    uint16_t short_value;
    uint8_t char_value;
  };
  uint32_t register_values[0];
} CliRom_st;




#endif

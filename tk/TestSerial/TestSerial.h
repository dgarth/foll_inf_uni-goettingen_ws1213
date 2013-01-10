
#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H

typedef nx_struct test_serial_msg {
  nx_uint8_t cmd;
  nx_uint8_t params[25];
  nx_uint8_t length;
  nx_uint8_t moreData;
} test_serial_msg_t;

enum {
  AM_TEST_SERIAL_MSG = 0x89,
};

#endif

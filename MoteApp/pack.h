/* 
helper functions to work with bytearrays

usage:

    pack(uint8_t *buf, const char *fmt, ...);

        similar to sprintf():
        put all arguments in "..." into the buffer, according to the format
        string "fmt", in a way that they can be easily retrieved with unpack()


    unpack(const uint8_t *buf, const char *fmt, ...);

        similar to sscanf():
        retrieves data from the buffer according to "fmt". arguments in "..."
        must be pointers to appropriate types.


    format specifiers:
        b   = int8_t    B   = uint8_t
        h   = int16_t   H   = uint16_t
        i   = int32_t   I   = uint32_t
        l   = int64_t   L   = uint64_t

    example:
        uint8_t a;
        uint16_t b = 1337;
        int32_t c = -12345678;

        pack(buf, "BHi", 255, b, c);
        unpack(buf, "BHi", &a, &b, &c);

        assert(a == 255);
        assert(b == 1337);
        assert(c == -12345678);
 */
#ifndef PACK_H
#define PACK_H

#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>

static size_t pack(uint8_t *buf, const char *fmt, ...);
static size_t unpack(const uint8_t *buf, const char *fmt, ...);


static void buffer_put(uint8_t *buffer, uint64_t value, size_t bytes);
static uint64_t buffer_get(const uint8_t *buffer, size_t bytes);


#define PACK_UNPACK(c, name, CASE)                          \
static size_t name(c uint8_t *buf, const char *fmt, ...)    \
{                                                           \
    va_list ap;                                             \
    size_t sz, total = 0;                                   \
                                                            \
    va_start(ap, fmt);                                      \
                                                            \
    for (; *fmt; fmt++)                                     \
    {                                                       \
        switch (*fmt)                                       \
        {                                                   \
            CASE('b', int, int8_t);                         \
            CASE('B', int, uint8_t);                        \
                                                            \
            CASE('h', int, int16_t);                        \
            CASE('H', int, uint16_t);                       \
                                                            \
            CASE('i', int32_t, int32_t);                    \
            CASE('I', uint32_t, uint32_t);                  \
                                                            \
            CASE('l', int64_t, int64_t);                    \
            CASE('L', uint64_t, uint64_t);                  \
                                                            \
            default:                                        \
                return total;                               \
        }                                                   \
                                                            \
        buf += sz;                                          \
        total += sz;                                        \
    }                                                       \
                                                            \
    va_end(ap);                                             \
                                                            \
    return total;                                           \
}

#define CASE_PACK(chr, ap_type, type)       \
    case chr:                               \
        {                                   \
            type val = va_arg(ap, ap_type); \
            sz = sizeof (type);             \
            buffer_put(buf, val, sz);       \
        }                                   \
        break

#define CASE_UNPACK(chr, ap_type, type)     \
    case chr:                               \
        {                                   \
            type *p = va_arg(ap, type*);    \
            sz = sizeof (type);             \
            *p = buffer_get(buf, sz);       \
        }                                   \
        break


/* define pack() */
PACK_UNPACK(, pack, CASE_PACK)

/* define unpack() */
PACK_UNPACK(const, unpack, CASE_UNPACK)


static void buffer_put(uint8_t *buffer, uint64_t value, size_t bytes)
{
    while (bytes--)
    {
        buffer[bytes] = value & 0xFF;
        value >>= 8;
    }
}

static uint64_t buffer_get(const uint8_t *buffer, size_t bytes)
{
    uint64_t value = 0;
    const uint8_t *end = buffer+bytes;

    while (buffer < end)
    {
        value <<= 8;
        value += *buffer++;
    }

    return value;
}

#ifdef TEST

#include <assert.h>
#include <inttypes.h>
#include <stdio.h>

int main(void)
{
    uint8_t buf[100];

#define test(T, FMT, PRI, TMIN, TMAX)       \
{                                           \
    T a = TMIN, b = TMAX, a2, b2;           \
    pack(buf, FMT FMT, a, b);               \
    unpack(buf, FMT FMT, &a2, &b2);         \
    assert(a == a2);                        \
    assert(b == b2);                        \
}

    test(uint64_t, "L", PRIu64, 0, UINT64_MAX);
    test(int64_t,  "l", PRId64, INT64_MIN, INT64_MAX);

    test(uint32_t, "I", PRIu32, 0, UINT32_MAX);
    test(int32_t,  "i", PRId32, INT32_MIN, INT32_MAX);

    test(uint16_t, "H", PRIu16, 0, UINT16_MAX);
    test(int16_t,  "h", PRId16, INT16_MIN, INT16_MAX);

    test(uint8_t,  "B", PRIu8, 0, UINT8_MAX);
    test(int8_t,   "b", PRId8, INT8_MIN, INT8_MAX);

    puts("all ok");
    return 0;
}

#endif // TEST
#endif // PACK_H

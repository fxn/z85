// Ruby C extension of Z85 based on the reference C implementation found in
//
//    https://github.com/zeromq/rfc/blob/master/src/spec_32.c
//

// Original header:
//
//  --------------------------------------------------------------------------
//  Copyright (c) 2010-2013 iMatix Corporation and Contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//  --------------------------------------------------------------------------

#include <stdlib.h>
#include <stdint.h>
#include <ruby/ruby.h>

typedef unsigned char byte;

static VALUE z85_error;

static char encoder[85 + 1] = {
    "0123456789"
    "abcdefghij"
    "klmnopqrst"
    "uvwxyzABCD"
    "EFGHIJKLMN"
    "OPQRSTUVWX"
    "YZ.-:+=^!/"
    "*?&<>()[]{"
    "}@%$#"
};

static byte decoder[96] = {
    0x00, 0x44, 0x00, 0x54, 0x53, 0x52, 0x48, 0x00,
    0x4B, 0x4C, 0x46, 0x41, 0x00, 0x3F, 0x3E, 0x45,
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x40, 0x00, 0x49, 0x42, 0x4A, 0x47,
    0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A,
    0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32,
    0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A,
    0x3B, 0x3C, 0x3D, 0x4D, 0x00, 0x4E, 0x43, 0x00,
    0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
    0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
    0x21, 0x22, 0x23, 0x4F, 0x00, 0x50, 0x00, 0x00
};

static VALUE z85_encode(VALUE _mod, VALUE string)
{
    byte* data = (byte*) StringValuePtr(string);
    long size = RSTRING_LEN(string);

    size_t encoded_len = size * 5 / 4;
    char* encoded = xmalloc(encoded_len + 1);
    uint char_nbr = 0;
    uint byte_nbr = 0;
    uint32_t value = 0;

    while (byte_nbr < size) {
        value = value * 256 + data[byte_nbr++];
        if (byte_nbr % 4 == 0) {
            uint divisor = 85 * 85 * 85 * 85;
            while (divisor) {
                encoded[char_nbr++] = encoder[value / divisor % 85];
                divisor /= 85;
            }
            value = 0;
        }
    }
    encoded[char_nbr] = 0;

    VALUE out = rb_usascii_str_new_cstr(encoded);
    xfree(encoded);
    return out;
}

static VALUE z85_decode(VALUE _mod, VALUE rstring)
{
    char* string = StringValuePtr(rstring);
    long strlen = RSTRING_LEN(rstring);
    if (strlen % 5)
      strlen--; /* It is padded, ignore the counter */

    size_t decoded_size = strlen * 4 / 5;
    byte* decoded = xmalloc(decoded_size);

    uint byte_nbr = 0;
    uint char_nbr = 0;
    uint32_t value = 0;
    while (char_nbr < strlen) {
        value = value * 85 + decoder[(byte) string[char_nbr++] - 32];
        if (char_nbr % 5 == 0) {
            uint divisor = 256 * 256 * 256;
            while (divisor) {
                decoded[byte_nbr++] = value / divisor % 256;
                divisor /= 256;
            }
            value = 0;
        }
    }

    VALUE out = rb_str_new((const char*) decoded, decoded_size);
    xfree(decoded);
    return out;
}

static VALUE z85_extract_counter(VALUE _mod, VALUE encoded)
{
    char* string = StringValuePtr(encoded);
    char counter = string[RSTRING_LEN(encoded) - 1] - '0';
    if (0 <= counter && counter <= 3) {
        return INT2FIX(counter);
    } else {
        rb_raise(z85_error, "Invalid counter: %c", counter + '0');
    }
}

/* This function has a special name and it is invoked by Ruby to initialize the extension. */
void Init_z85()
{
    VALUE z85 = rb_define_module("Z85");
    VALUE z85_singleton_class = rb_singleton_class(z85);

    z85_error = rb_define_class_under(z85, "Error", rb_eStandardError);

    rb_define_private_method(z85_singleton_class, "_encode", z85_encode, 1);
    rb_define_private_method(z85_singleton_class, "_decode", z85_decode, 1);
    rb_define_private_method(z85_singleton_class, "extract_counter", z85_extract_counter, 1);
}

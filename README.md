# Z85

[![Gem Version](https://img.shields.io/gem/v/z85.svg?style=for-the-badge)](https://rubygems.org/gems/z85)
[![Build Status](https://img.shields.io/travis/com/fxn/z85.svg?style=for-the-badge&branch=master)](https://travis-ci.com/fxn/z85)

`z85` is a Ruby gem written in C for [Z85](https://rfc.zeromq.org/spec:32/Z85/) encoding.

## Z85 proper

Z85 as such is provided by the methods `encode`/`decode`:

```ruby
# 💣 USE THESE ONLY IF YOU KNOW WHAT YOU ARE DOING.
Z85.encode("\x86O\xD2o\xB5Y\xF7[") # => "HelloWorld"
Z85.decode("HelloWorld")           # => "\x86O\xD2o\xB5Y\xF7["
```

The string returned by `decode` has encoding `Encoding::ASCII_8BIT`, also known as `Encoding::BINARY`.

## Z85 with padding

Z85 requires the input to have a number of bytes divisible by 4, so you cannot pass arbitrary arguments to `encode`.

To address this, `z85` provides `*_with_padding` variants of the methods that are able to handle any binary:

```ruby
# 👍 USE THESE ONES FOR ARBITRARY BINARIES.
Z85.encode_with_padding("\x86O\xD2o\xB5Y\xF7[") # => "HelloWorld4"
Z85.decode_with_padding("HelloWorld4")          # => "\x86O\xD2o\xB5Y\xF7["
```

The string returned by `decode_with_padding` has encoding `Encoding::ASCII_8BIT`, also known as `Encoding::BINARY`.

### How does padding work?

The method `encode_with_padding` appends as many `\0`s as needed to the input, and stores a trailing digit from 1 to 4 indicating how many extra `NUL`s there are (with 4 meaning none).

On the other side, `decode_with_padding` removes the counter, and chops the `\0`s accordingly.

Padding support was inspired by https://github.com/artemkin/z85.

### Interoperability warning

Since padding does not belong to the Z85 specification, if you encode with padding using `z85`, and decode using another library, the decoding end will probably need to implement what [`decode_with_padding`](https://github.com/fxn/z85/blob/master/lib/z85.rb) does. Should be straightforward.

## Implementation details

To be as faithful to the spec as possible, `z85` takes the [C reference implementation](https://github.com/zeromq/rfc/blob/master/src/spec_32.c) and performs the minimal changes needed to integrate it with the Ruby C API.

The [test suite](https://github.com/fxn/z85/blob/master/test/lib/test_z85.rb) contains the reference C test suite, and adds roundtrip verifications for [a variety of files](https://github.com/fxn/z85/tree/master/test/fixtures).

## License

Released under the MIT License, Copyright (c) 2019–<i>ω</i> Xavier Noria.

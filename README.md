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

Strings returned by `encode` have encoding `Encoding::US_ASCII`, and the ones returned by `decode` have encoding `Encoding::ASCII_8BIT`, also known as `Encoding::BINARY`.

## Z85 with padding

Z85 requires the input to have a number of bytes divisible by 4, so you cannot pass arbitrary arguments to `encode`.

To address this, `z85` provides `*_with_padding` variants of the methods that are able to handle any binary:

```ruby
# 👍 USE THESE ONES FOR ARBITRARY BINARIES.
"\x86O".bytesize                  # => 2, no problem
Z85.encode_with_padding("\x86O")  # => "Hed^H2"
Z85.decode_with_padding("Hed^H2") # => "\x86O"
```

Strings returned by `encode_with_padding` have encoding `Encoding::US_ASCII`, and the ones returned by `decode_with_padding` have encoding `Encoding::ASCII_8BIT`, also known as `Encoding::BINARY`.

### How does padding work?

Given "foo", the method `encode_with_padding` does this:

1. Since "foo" has three bytes, the method appends one `\0`: "foo\0".
2. Encodes that padded string, which yields "w]zO/".
3. Appends the counter, returning "w]zO/1".

The method `decode_with_padding` just undoes that, so given "e=U>K3":

1. Chops the counter, obtaining "w]zO/".
2. Decodes that string, which yields "foo\0".
3. Chops as many `\0`s as the counter says, returning "foo".

Padding support was inspired by https://github.com/artemkin/z85.

### Interoperability warning

Since padding does not belong to the Z85 specification, if you encode with padding using `z85`, and decode using another library, the decoding end will probably need to implement what `decode_with_padding` does. Should be straightforward, just emulate what is described in the previous section.

## Implementation details

To be as faithful to the spec as possible, `z85` takes the [C reference implementation](https://github.com/zeromq/rfc/blob/master/src/spec_32.c) and performs the minimal changes needed to integrate it with the Ruby C API.

The [test suite](https://github.com/fxn/z85/blob/master/test/lib/test_z85.rb) contains the reference C test suite, and adds roundtrip verifications for [a variety of files](https://github.com/fxn/z85/tree/master/test/fixtures).

## License

Released under the MIT License, Copyright (c) 2019–<i>ω</i> Xavier Noria.

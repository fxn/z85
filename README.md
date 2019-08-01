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
Z85.encode_with_padding("\x86O\xD2o\xB5Y\xF7[") # => "HelloWorld0"
Z85.decode_with_padding("HelloWorld0")          # => "\x86O\xD2o\xB5Y\xF7["
```

The string returned by `decode_with_padding` has encoding `Encoding::ASCII_8BIT`, also known as `Encoding::BINARY`.

### How does padding work?

The method `encode_with_padding` appends as many `\0`s as needed to the input, and stores a trailing digit from 0 to 3 indicating how many there are. For example, given ".":

1. Since "." has 1 byte, the method appends three `\0`s: ".\0\0\0".
2. Encodes that padded string, which yields "e=U>K".
3. Appends the counter, returning "e=U>K3".

Given a padded string, `decode_with_padding` removes the counter from the end, decodes, and chops the `\0`s from the result. In the example above:

1. Given "e=U>K3", the method chops the counter, obtaining "e=U>K".
2. Decodes that string, which yields ".\0\0\0".
3. Chops as many `\0`s as the counter says, returning ".".

Padding support was inspired by https://github.com/artemkin/z85.

### Interoperability warning

Since padding does not belong to the Z85 specification, if you encode with padding using `z85`, and decode using another library, the decoding end will probably need to implement what `decode_with_padding` does. Should be straightforward, just emulate what is described in the previous section.

## Implementation details

To be as faithful to the spec as possible, `z85` takes the [C reference implementation](https://github.com/zeromq/rfc/blob/master/src/spec_32.c) and performs the changes needed to integrate it with the Ruby C API.

The [test suite](https://github.com/fxn/z85/blob/master/test/lib/test_z85.rb) contains the reference C test suite, and adds roundtrip verifications for [a variety of files](https://github.com/fxn/z85/tree/master/test/fixtures).

## License

Released under the MIT License, Copyright (c) 2019–<i>ω</i> Xavier Noria.

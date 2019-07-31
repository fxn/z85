# Z85

## Usage

`z85` is a Ruby gem written in C for [Z85](https://rfc.zeromq.org/spec:32/Z85/) encoding.

Straight Z85 is provided by the methods `encode`/`decode`:

```
> binary = "\x86\x4F\xD2\x6F\xB5\x59\xF7\x5B".force_encoding(Encoding::BINARY)
=> "\x86O\xD2o\xB5Y\xF7["
> encoded = Z85.encode(binary)
=> "HelloWorld"
> Z85.decode(encoded)
=> "\x86O\xD2o\xB5Y\xF7["
```

However, Z85 requires binaries to have a number of bytes which is a multiple of 4. Generic binaries may not satisfy that.

To address this, `z85` provides `*_with_padding` variants of the methods that adjust and remove padding to be able to handle arbitrary input. For example, if you want to store a binary payload in a JSON string, you probably want this combo instead:

```ruby
encoded = Z85.encode_with_padding(binary)
decoded = Z85.decode_with_padding(encoded)
```

The method `encode_with_padding` appends as many `\0`s as needed to the input, and stores a trailing digit from 1 to 4 indicating how many extra `NUL`s there are (with 4 meaning none).

On the other side, `decode_with_padding` removes the counter, and chops the `\0`s accordingly.

Padding support was inspired by https://github.com/artemkin/z85.

## Implementation details

To be as faithful to the spec as possible, `z85` on purpose takes the [C reference implementation](https://github.com/zeromq/rfc/blob/master/src/spec_32.c) and performs the minimal changes needed to integrate it with the Ruby C API.

The [test suite](https://github.com/fxn/z85/blob/master/test/lib/test_z85.rb) contains the reference C test suite, and adds roundtrip verifications for [a variety of files](https://github.com/fxn/z85/tree/master/test/fixtures).

## License

Released under the MIT License, Copyright (c) 2019–<i>ω</i> Xavier Noria.

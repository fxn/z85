# frozen_string_literal: true

require "test_helper"

class TestZ85 < Minitest::Test
  def string_from_bytes(chars)
    chars.pack("C*").force_encoding(Encoding::BINARY)
  end

  def assert_z85(encoded, bytes)
    binary = string_from_bytes(bytes)

    assert_equal encoded, Z85.encode(binary)
    assert_equal encoded + "0", Z85.encode_with_padding(binary)

    assert_equal binary, Z85.decode(encoded)
    assert_equal binary, Z85.decode_with_padding(encoded + "0")
  end

  test "encoding the empty string" do
    assert_z85 "", []
  end

  test "encoding a short binary" do
    assert_z85 "HelloWorld", [
      0x86, 0x4F, 0xD2, 0x6F, 0xB5, 0x59, 0xF7, 0x5B
    ]
  end

  test "client public key in zmq_curve man page" do
    assert_z85 "Yne@$w-vo<fVvi]a<NY6T1ed:M$fCG*[IaLV{hID", [
      0xBB, 0x88, 0x47, 0x1D, 0x65, 0xE2, 0x65, 0x9B,
      0x30, 0xC5, 0x5A, 0x53, 0x21, 0xCE, 0xBB, 0x5A,
      0xAB, 0x2B, 0x70, 0xA3, 0x98, 0x64, 0x5C, 0x26,
      0xDC, 0xA2, 0xB2, 0xFC, 0xB4, 0x3F, 0xC5, 0x18
    ]
  end

  test "client secret key in zmq_curve man page" do
    assert_z85 "D:)Q[IlAW!ahhC2ac:9*A}h:p?([4%wOTJ%JR%cs", [
      0x7B, 0xB8, 0x64, 0xB4, 0x89, 0xAF, 0xA3, 0x67,
      0x1F, 0xBE, 0x69, 0x10, 0x1F, 0x94, 0xB3, 0x89,
      0x72, 0xF2, 0x48, 0x16, 0xDF, 0xB0, 0x1B, 0x51,
      0x65, 0x6B, 0x3F, 0xEC, 0x8D, 0xFD, 0x08, 0x88
    ]
  end

  test "server public key in zmq_curve man page" do
    assert_z85 "rq:rM>}U?@Lns47E1%kR.o@n%FcmmsL/@{H8]yf7", [
      0x54, 0xFC, 0xBA, 0x24, 0xE9, 0x32, 0x49, 0x96,
      0x93, 0x16, 0xFB, 0x61, 0x7C, 0x87, 0x2B, 0xB0,
      0xC1, 0xD1, 0xFF, 0x14, 0x80, 0x04, 0x27, 0xC5,
      0x94, 0xCB, 0xFA, 0xCF, 0x1B, 0xC2, 0xD6, 0x52
    ]
  end

  test "server secret key in zmq_curve man page" do
    assert_z85 "JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6", [
      0x8E, 0x0B, 0xDD, 0x69, 0x76, 0x28, 0xB9, 0x1D,
      0x8F, 0x24, 0x55, 0x87, 0xEE, 0x95, 0xC5, 0xB0,
      0x4D, 0x48, 0x96, 0x3F, 0x79, 0x25, 0x98, 0x77,
      0xB4, 0x9C, 0xD9, 0x06, 0x3A, 0xEA, 0xD3, 0xB7
    ]
  end

  test "fixture encoding roundtrips" do
    each_fixture do |fixture|
      binary = File.binread(fixture)
      assert_equal binary, Z85.decode_with_padding(Z85.encode_with_padding(binary))
    end
  end

  test "encode returns a string with the locale encoding" do
    assert_equal Encoding::US_ASCII, Z85.encode("\x86O\xD2o\xB5Y\xF7[").encoding
  end

  test "encode_with_padding returns a string with the locale encoding" do
    assert_equal Encoding::US_ASCII, Z85.encode_with_padding("\x86O\xD2o\xB5Y\xF7[").encoding
  end

  test "decode returns a binary string" do
    assert_equal Encoding::BINARY, Z85.decode("HelloWorld").encoding
  end

  test "decode_with_padding returns a binary string" do
    assert_equal Encoding::BINARY, Z85.decode_with_padding("HelloWorld0").encoding
  end

  test "encode raises if the length of the binary is not a multiple of 4" do
    1.upto(3) do |n|
      e = assert_raises(Z85::Error) { Z85.encode("\0" * n) }
      assert_equal "Input length should be 0 mod 4. Please, check Z85.encode_with_padding.", e.message
    end
  end

  test "encode raises if the length of an encoded string is not a multiple of 5" do
    1.upto(4) do |n|
      e = assert_raises(Z85::Error) { Z85.decode("\0" * n) }
      assert_equal "Input length should be 0 mod 5. Please, check Z85.decode_with_padding.", e.message
    end
  end

  test "passing unexpected objects raises StandardError" do
    [nil, 1, [], {}, Object.new].each do |unexpected_object|
      assert_raises(StandardError) { Z85.encode(unexpected_object) }
      assert_raises(StandardError) { Z85.decode(unexpected_object) }
    end
  end

  test "decode_with_padding raises if the counter is invalid" do
    e = assert_raises(Z85::Error) { Z85.decode_with_padding("HelloWorld7") }
    assert_equal "Invalid counter: 7", e.message

    e = assert_raises(Z85::Error) { Z85.decode_with_padding("HelloWorldX") }
    assert_equal "Invalid counter: X", e.message
  end

  test "decode_with_padding raises if the padding length is too large" do
    e = assert_raises(Z85::Error) { Z85.decode_with_padding("1") }
    assert_equal "String too short for counter 1", e.message
  end
end

# frozen_string_literal: true

require "z85/z85"
require "z85/version"

module Z85
  def self.encode_with_padding(string)
    padding_length = 4 - (string.bytesize % 4)
    string += "\0" * padding_length unless padding_length == 4
    encode(string) + padding_length.to_s
  end

  def self.decode_with_padding(encoded)
    padding_length = encoded[-1].to_i

    unless 1 <= padding_length && padding_length <= 4
      raise "Invalid padding length #{padding_length}"
    end

    decoded = decode(encoded.chop)
    padding_length.times { decoded.chop! } unless padding_length == 4

    decoded
  end
end

require "z85/z85"
require "z85/version"

module Z85
  def self.encode_with_padding(string)
    rem = string.bytesize % 4
    string += "\0" * (4 - rem) unless rem == 0
    encode(string) + rem.to_s
  end

  def self.decode_with_padding(encoded)
    rem = encoded[-1].to_i
    decoded = decode(encoded.chop!)
    (4 - rem).times { decoded.chop! } unless rem == 0
    decoded
  end
end

# frozen_string_literal: true

require "z85/z85"
require "z85/version"

module Z85
  PADDINGS = ["", "\0", "\0\0", "\0\0\0"].freeze
  private_constant :PADDINGS

  class Error < StandardError; end

  class << self
    private def err(message)
      raise Error, message
    end

    def encode(string)
      if string.bytesize % 4 != 0
        err "Input length should be 0 mod 4. Please, check Z85.encode_with_padding."
      end
      _encode(string)
    end

    def encode_with_padding(string)
      counter = 4 - (string.bytesize % 4)
      counter == 4 ? _encode(string) + "0" : _encode(string + PADDINGS[counter]) + counter.to_s
    end

    def decode(string)
      if string.bytesize % 5 != 0
        err "Input length should be 0 mod 5. Please, check Z85.decode_with_padding."
      end
      _decode(string)
    end

    def decode_with_padding(string)
      err "Input length should be 1 mod 5" if string.bytesize % 5 != 1

      counter = string[-1]
      err "Invalid counter: #{counter}" if counter < "0" || counter > "3"

      decoded = _decode(string)
      size = decoded.bytesize - counter.to_i
      err "String too short for counter #{counter}" if size < 0

      decoded.slice!(0, size)
    end
  end
end

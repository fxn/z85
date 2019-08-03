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
        err "Number of bytes should be 0 mod 4. Please, check Z85.encode_with_padding."
      end

      _encode(string)
    end

    def encode_with_padding(string)
      n  = 4 - (string.bytesize % 4)
      n == 4 ? _encode(string) + "0" : _encode(string + PADDINGS[n]) + n.to_s
    end

    def decode(string)
      if string.bytesize % 5 != 0
        err "Input length should be 0 mod 5. Please, check Z85.decode_with_padding."
      end

      _decode(string)
    end

    def decode_with_padding(string)
      if string.bytesize % 5 != 1
        err "Input length should be 1 mod 5"
      end

      counter = extract_counter(string)
      decoded = _decode(string)

      begin
        decoded[-counter, counter] = ""
      rescue IndexError
        err "String too short for counter #{counter}"
      end

      decoded
    end

    private def extract_counter(string)
      begin
        counter = Integer(string[-1])
      rescue ArgumentError
        err "Invalid counter: #{string[-1]}"
      end

      if counter <= 3
        counter
      else
        err "Invalid counter: #{counter}"
      end
    end
  end
end

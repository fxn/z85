# frozen_string_literal: true

require "z85/z85"
require "z85/version"

module Z85
  def self.encode_with_padding(string)
    counter = 4 - (string.bytesize % 4)
    counter = 0 if counter == 4
    string += "\0" * counter if counter > 0
    encode(string) + counter.to_s
  end
end

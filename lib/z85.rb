# frozen_string_literal: true

require "z85/z85"
require "z85/version"

module Z85
  def self.encode_with_padding(string)
    padding_length = 4 - (string.bytesize % 4)
    padding_length = 0 if padding_length == 4
    string += "\0" * padding_length if padding_length > 0
    encode(string) + padding_length.to_s
  end
end

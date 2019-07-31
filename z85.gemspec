$: << File.expand_path("lib", __dir__)
require "z85/version"

Gem::Specification.new do |spec|
  spec.name     = "z85"
  spec.version  = Z85::VERSION
  spec.licenses = ["MIT"]
  spec.summary  = "Z85 encoding"
  spec.homepage = "https://github.com/fxn/z85"
  spec.author   = "Xavier Noria"
  spec.email    = "fxn@hashref.com"

  spec.extensions = %w(ext/z85/extconf.rb)
  spec.require_paths = %w(lib)
  spec.files = %w(
    ext/z85/extconf.rb
    ext/z85/z85.c
    lib/z85.rb
    lib/z85/version.rb
  )
end

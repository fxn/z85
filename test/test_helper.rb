require "minitest/autorun"
require "minitest/focus"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require_relative "support/test_macro"

Minitest::Test.class_eval do
  extend TestMacro
end

require "z85"

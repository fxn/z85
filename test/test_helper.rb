# frozen_string_literal: true

require "minitest/autorun"
require "minitest/focus"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require_relative "support/test_macro"

Minitest::Test.class_eval do
  extend TestMacro

  def each_fixture
    fixtures_dir = "#{__dir__}/fixtures"
    Dir.new(fixtures_dir).each do |fixture|
      yield "#{fixtures_dir}/#{fixture}" unless fixture.start_with?(".")
    end
  end
end

require "z85"

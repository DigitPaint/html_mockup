# Generators register themself on the CLI module
require "./lib/html_mockup/generators.rb"
require "test/unit"



module CustomGens
  module Generators

    class MockedGenerator < HtmlMockup::Generators::Base
      def test
	# Somewhat ugly way of checking
	raise NotImplementedError
      end
    end

  end
end


module HtmlMockup
  class GeneratorTest < Test::Unit::TestCase

    def test_register_generator
      assert_includes Generators::Generate.commands, "mocked"
    end

    def test_default_generator
      assert_includes Generators::Generate.commands, "new"
    end

    def test_invoke_mocked_generator
      generators = Generators::Generate.new

      assert_raise NotImplementedError do
	generators.invoke :mocked
      end

    end

  end
end
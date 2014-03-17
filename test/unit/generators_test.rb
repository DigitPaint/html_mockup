# Generators register themself on the CLI module
require "./lib/html_mockup/generators.rb"
require "test/unit"


module CustomGens
  module Generators

    class MockedGenerator < HtmlMockup::Generators::Base

      desc "@mocked description"
      argument :path, :type => :string, :required => false, :desc => "Path to generate mockup into"
      argument :another_arg, :type => :string, :required => false, :desc => "Mocked or what?!"
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
      HtmlMockup::Generators::Base.register CustomGens::Generators::MockedGenerator
      assert_includes Generators::Generate.tasks, "mocked"
      assert_equal Generators::Generate.tasks["mocked"].description, "@mocked description"
      assert_equal Generators::Generate.tasks["mocked"].usage, "mocked PATH ANOTHER_ARG"
    end

    def test_default_generator
      assert_includes Generators::Generate.tasks, "new"
    end

    def test_invoke_mocked_generator
      generators = Generators::Generate.new

    def test_invoke_mocked_generator
      HtmlMockup::Generators::Base.register CustomGens::Generators::MockedGenerator

      generators = Generators::Generate.new
      assert_raise NotImplementedError do
	generators.invoke :mocked
      end
    end
  end
end
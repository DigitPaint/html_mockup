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

    class MockedWithProjectGenerator < HtmlMockup::Generators::Base

      desc "Returns a project"
      def test
        # Somewhat ugly way of checking
        raise StandardError if @project
      end
    end    

  end
end

module HtmlMockup
  class GeneratorTest < Test::Unit::TestCase
    def setup
      @cli = Cli::Base.new
    end

    def test_working_project
      HtmlMockup::Generators::Base.register CustomGens::Generators::MockedWithProjectGenerator
      generators = Cli::Generate.new

      assert_raise StandardError do
        generators.invoke "mockedwithproject"
      end
    end

    def test_register_generator
      HtmlMockup::Generators::Base.register CustomGens::Generators::MockedGenerator
      assert_includes Cli::Generate.tasks, "mocked"
      assert_equal Cli::Generate.tasks["mocked"].description, "@mocked description"
      assert_equal Cli::Generate.tasks["mocked"].usage, "mocked PATH ANOTHER_ARG"
    end

    def test_default_generator
      assert_includes Cli::Generate.tasks, "new"
    end

    def test_generator_generator
      generators = Cli::Generate.new
      name = "tralal"
      path = "./tmp"
      generators.invoke :generator, [name, path]
      assert File.exist? "#{path}/#{name}_generator.rb"
    end

    def test_invoke_mocked_generator
      HtmlMockup::Generators::Base.register CustomGens::Generators::MockedGenerator
      
      generators = Cli::Generate.new
      assert_raise NotImplementedError do
        generators.invoke :mocked
      end
    end
  end
end
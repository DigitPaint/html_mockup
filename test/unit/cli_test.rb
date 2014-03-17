require "./lib/html_mockup/cli.rb"
require "test/unit"

module HtmlMockup
  class CliTest < Test::Unit::TestCase

    def test_register_generators
      assert_includes Cli.subcommands, "generate"
    end

  end
end
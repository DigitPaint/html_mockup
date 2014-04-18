# Generators register themself on the CLI module
require "./lib/html_mockup/resolver.rb"
require "test/unit"

module HtmlMockup
  class ResolverTest < Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../project/html")
      @resolver = HtmlMockup::Resolver.new(@base)
    end

    def test_find_template_path
      assert_equal @resolver.find_template("formats/mockup.html"), @base + "formats/mockup.html"

      # This should not be found on it's own as it will be processed
      assert_equal @resolver.find_template("formats/markdown.md"), nil
    end

    def test_find_template_index_path
      assert_equal @resolver.find_template("formats"), @base + "formats/index.html"
    end

    def test_find_template_html_without_extension
      assert_equal @resolver.find_template("formats/index"), @base + "formats/index.html"
      assert_equal @resolver.find_template("formats/erb"), @base + "formats/erb.html.erb"
    end

    def test_find_template_with_template_extension
      assert_equal @resolver.find_template("formats/markdown"), @base + "formats/markdown.md"
    end  

    def test_find_template_with_double_extensions
      assert_equal @resolver.find_template("formats/erb"), @base + "formats/erb.html.erb"
      assert_equal @resolver.find_template("formats/erb.html"), @base + "formats/erb.html.erb"

      assert_equal @resolver.find_template("formats/json.json"), @base + "formats/json.json.erb"
    end    

    def test_find_template_with_preferred_extension
      assert_equal @resolver.find_template("formats/json", :preferred_extension => "json"), @base + "formats/json.json.erb"
    end
    
    def test_find_template_exact_match
      # TODO
    end

  end
end
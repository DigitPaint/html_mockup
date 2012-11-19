require "./lib/html_mockup/release.rb"
require "./lib/html_mockup/release/cleaner.rb"
require "pry"
require "test/unit"

class CleanerTest < Test::Unit::TestCase

  def test_only_clean_inside_build_path
    pattern = "processors"
    cleaner = HtmlMockup::Release::Cleaner.new(pattern)
    inside_build_path = cleaner.send :inside_build_path, File.dirname(__FILE__), pattern

    assert(inside_build_path, "Only delete content inside build_path")
  end  
  
  def test_dont_clean_outside_build_path
    pattern = "../../../lib"
    cleaner = HtmlMockup::Release::Cleaner.new(pattern)

    assert_raise RuntimeError do
      inside_build_path = cleaner.send :inside_build_path, File.dirname(__FILE__), pattern
    end

  end

end

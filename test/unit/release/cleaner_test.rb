require "./lib/html_mockup/release.rb"
require "./lib/html_mockup/release/cleaner.rb"
require "test/unit"

class CleanerTest < Test::Unit::TestCase

  def setup
    @base = File.dirname(__FILE__) + "/../../project"
  end

  def test_only_clean_inside_build_path_relative
  
    cleaner = HtmlMockup::Release::Cleaner.new(@base)
    inside_build_path = cleaner.send :is_inside_build_path, @base, @base + "/html/formats"

    assert(inside_build_path, "Only delete content inside build_path")
  end  

  def test_only_clean_inside_build_path_absolute
    path = Pathname.new(@base).realpath.to_s
    cleaner = HtmlMockup::Release::Cleaner.new(path)

    inside_build_path = cleaner.send :is_inside_build_path, path, @base + "/html/formats"

    assert(inside_build_path, "Only delete content inside build_path")
  end  

  
  def test_dont_clean_outside_build_path
    path = File.dirname(__FILE__)
    cleaner = HtmlMockup::Release::Cleaner.new(path)

    assert_raise RuntimeError do
      inside_build_path = cleaner.send :is_inside_build_path, path, @base + "/html/formats"
    end

  end
  
  def test_dont_fail_on_nonexistent_files
    path = "bla"
    cleaner = HtmlMockup::Release::Cleaner.new(path)

    assert !cleaner.send(:is_inside_build_path, @base + "/html/formats", path), "Failed on nonexistent directories/files"

  end  

end

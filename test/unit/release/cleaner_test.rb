require "./lib/html_mockup/release.rb"
require "./lib/html_mockup/release/cleaner.rb"
require "test/unit"

class CleanerTest < Test::Unit::TestCase

  def test_only_clean_inside_build_path_relative
    path = "processors"
    cleaner = HtmlMockup::Release::Cleaner.new(path)
    inside_build_path = cleaner.send :is_inside_build_path, File.dirname(__FILE__), path

    assert(inside_build_path, "Only delete content inside build_path")
  end  

  def test_only_clean_inside_build_path_absolute
    path = Pathname.new(File.dirname(__FILE__) + "/processors").realpath.to_s
    cleaner = HtmlMockup::Release::Cleaner.new(path)
    inside_build_path = cleaner.send :is_inside_build_path, File.dirname(__FILE__), path

    assert(inside_build_path, "Only delete content inside build_path")
  end  

  
  def test_dont_clean_outside_build_path
    path = "../../../lib"
    cleaner = HtmlMockup::Release::Cleaner.new(path)

    assert_raise RuntimeError do
      inside_build_path = cleaner.send :is_inside_build_path, File.dirname(__FILE__), path
    end

  end
  
  def test_dont_fail_on_nonexistent_files
    path = "bla"
    cleaner = HtmlMockup::Release::Cleaner.new(path)

    assert !cleaner.send(:is_inside_build_path, File.dirname(__FILE__), path), "Failed on nonexistent directories/files"

  end  

end

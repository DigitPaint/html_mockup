require "./lib/html_mockup/release.rb" 
require "./lib/html_mockup/release/processors/requirejs"
require "test/unit"

class RequireJS < Test::Unit::TestCase

  def test_requireJs_default_fallback
    # Just point options[:rjs] to a file to look if its there,
    # the user is expected to point to a correct r.js file if he really
    # doesn't want to use the r.js shipped with npm
    options = {:rjs => "s.js"}
    requirejs_processor = HtmlMockup::Release::Processors::Requirejs.new(options)
    rjs = options[:rjs]

    rjs_command = ''

    assert_raise RuntimeError do
      # The file does is there - it's this one, so it should raise
      rjs_command = requirejs_processor.rjs_check
    end

    # No command string is returned
    assert_equal rjs_command, ""
    
  end
  
  def test_requireJs_bin
    requirejs_processor = HtmlMockup::Release::Processors::Requirejs.new
    rjs = "r.js" # Default r.js by npm

    begin
      `#{rjs} -v`
    rescue Errno::ENOENT
      assert_raise RuntimeError do
        requirejs_processor.rjs_check
      end
    else
      requirejs_processor.rjs_check.assert(rjs)
    end
    
  end
  
  def test_requireJs_lib
    # Just point options[:rjs] to a file to look if its there,
    # the user is expected to point to a correct r.js file if he really
    # doesn't want to use the r.js shipped with npm
    options = {:rjs => __FILE__}
    requirejs_processor = HtmlMockup::Release::Processors::Requirejs.new(options)
    rjs = options[:rjs]

    rjs_command = ''

    assert_nothing_raised RuntimeError do
      # The file does is there - it's this one, so it should raise
      rjs_command = requirejs_processor.rjs_check
    end

    assert_equal rjs_command, "node #{rjs}"
    
  end
  
end

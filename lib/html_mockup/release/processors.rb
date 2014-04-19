module HtmlMockup::Release::Processors
  class Base
    
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end
  
    
    def call(release, options = {})
      raise ArgumentError, "Implement in subclass"
    end
  end
end

require File.dirname(__FILE__) + "/processors/mockup"
require File.dirname(__FILE__) + "/processors/url_relativizer"
require File.dirname(__FILE__) + "/processors/requirejs"
require File.dirname(__FILE__) + "/processors/sass"


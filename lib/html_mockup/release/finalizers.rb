module HtmlMockup::Release::Finalizers
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

require File.dirname(__FILE__) + "/finalizers/zip"
require File.dirname(__FILE__) + "/finalizers/dir"


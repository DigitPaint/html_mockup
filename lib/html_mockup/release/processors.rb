module HtmlMockup::Release::Processors
  class Base    
    def initialize(options = {})
      raise ArgumentError, "Implement in subclass"
    end
    def call(release, options = {})
      raise ArgumentError, "Implement in subclass"
    end
  end
end

require File.dirname(__FILE__) + "/finalizers/zip"
require File.dirname(__FILE__) + "/finalizers/dir"


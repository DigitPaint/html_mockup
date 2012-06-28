module HtmlMockup
  class Release::Scm
    
    attr_reader :config
    
    def initialize(config={})
      @config = config
    end
    
    # Returns the release version string from the SCM
    #
    # @return String The current version string
    def version
      raise "Implement in subclass"
    end
    
    # Returns the release version date from the SCM
    def date
      raise "Implement in subclass"      
    end
    
    # Returns a Release::Scm object with the previous version's data
    #
    # @return HtmlMockup::Release::Scm The previous version
    def previous
      raise "Implement in subclass"      
    end
    
  end
end

require File.dirname(__FILE__) + "/scm/git"

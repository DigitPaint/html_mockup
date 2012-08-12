module HtmlMockup
  # Loader for mockupfile
  class Mockupfile
    
    # @attr :path [Pathname] The path of the Mockupfile for this project
    attr_accessor :path, :project
        
    def initialize(project)
      @project = project
      @path = Pathname.new(project.path + "Mockupfile")
    end

    # Actually load the mockupfile
    def load
      if File.exist?(@path) && !self.loaded?
        @source = File.read(@path)
        eval @source, get_binding
        @loaded = true
      end      
    end
    
    # Wether or not the Mockupfile has been loaded
    def loaded?
      @loaded
    end
    
    def release
      if block_given?
        yield(self.project.release)
      end
      self.project.release      
    end
    
    def serve
      if block_given?
        yield(self.project.server)
      end
      self.project.server      
    end
    
    alias :server :serve
    
    protected
    
    def get_binding
      mockup = self
      binding
    end
    
  end
end

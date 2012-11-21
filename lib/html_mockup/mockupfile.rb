module HtmlMockup
  # Loader for mockupfile
  class Mockupfile
    
    # This is the context for the mockupfile evaluation. It should be empty except for the
    # #mockup method.
    class Context
      
      def initialize(mockupfile)
        @_mockupfile = mockupfile
      end
      
      def mockup
        @_mockupfile
      end
      
      def binding
        ::Kernel.binding
      end
      
    end
    
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
        context = Context.new(self)
        eval @source, context.binding, @path.to_s, 1
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
    
  end
end

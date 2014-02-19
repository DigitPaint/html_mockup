require File.dirname(__FILE__) + "/release"
require File.dirname(__FILE__) + "/server"
require File.dirname(__FILE__) + "/mockupfile"

module HtmlMockup
  # Loader for mockupfile and project dependencies
  class Project
    
    # @attr :path [Pathname] The project path
    # @attr :html_path [Pathname] The path of the HTML mockup
    # @attr :partial_path [Pathname] The path for the partials for this mockup
    # @attr :mockupfile [Mockupfile] The Mockupfile for this project
    attr_accessor :path, :html_path, :partial_path, :layouts_path, :mockupfile
    
    attr_accessor :shell
    
    attr_accessor :options
    
    def initialize(path, options={})
      @path = Pathname.new(path)
      
      @options = {
        :html_path => @path + "html",
        :partial_path => @path + "partials",
        :layouts_path => @path + "layouts"
      }
      
      # Clumsy string to symbol key conversion
      options.each{|k,v| @options[k.is_a?(String) ? k.to_sym : k] = v }
      
      self.html_path = @options[:html_path]
      self.partial_path = @options[:partials_path] || @options[:partial_path] || self.html_path + "../partials/"
      self.layouts_path = @options[:layouts_path]
      self.shell = @options[:shell]
      
      
      load_dependencies!
      load_mockup!
    end
    
    def shell
      @shell ||= Thor::Base.shell.new
    end
    
    def server
      options = @options[:server] || {}
      @server ||= Server.new(self, options)
    end
    
    def release
      options = @options[:release] || {}      
      @release ||= Release.new(self, options)
    end
    
    def html_path=(p)
      @html_path = self.realpath_or_path(p)
    end
    
    def partial_path=(p)
      @partial_path = self.realpath_or_path(p)
    end
    alias :partials_path :partial_path
    alias :partials_path= :partial_path=
    
    def layouts_path=(p)
      @layouts_path = self.realpath_or_path(p)
    end
    
    protected
    
    def load_dependencies!
      if Object.const_defined?(:Bundler)
        Bundler.require(:default)
      end
    end
    
    def load_mockup!
      @mockupfile = Mockupfile.new(self)
      @mockupfile.load      
    end
    
    def realpath_or_path(path)
      path = Pathname.new(path)
      if path.exist?
        path.realpath
      else
        path
      end      
    end
    
  end
end

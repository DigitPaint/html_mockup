require File.dirname(__FILE__) + "/release"
require File.dirname(__FILE__) + "/server"
require File.dirname(__FILE__) + "/mockupfile"

module HtmlMockup
  # Loader for mockupfile
  class Project
    
    # @attr :path [Pathname] The project path
    # @attr :html_path [Pathname] The path of the HTML mockup
    # @attr :partial_path [Pathname] The path for the partials for this mockup
    # @attr :mockupfile [Mockupfile] The Mockupfile for this project
    attr_accessor :path, :html_path, :partial_path, :layouts_path, :mockupfile
    
    def initialize(path, options={})
      @path = Pathname.new(path)
      
      @options = {
        :html_path => @path + "html",
        :partial_path => @path + "partials",
        :layouts_path => @path + "layouts"
      }.update(options)
      
      self.html_path = @options[:html_path]
      self.partial_path = @options[:partials_path] || @options[:partial_path] || self.html_path + "../partials/"
      self.layouts_path = @options[:layouts_path]
      
      @mockupfile = Mockupfile.new(self)
      @mockupfile.load
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
      @html_path = Pathname.new(p).realpath
    end
    
    def partial_path=(p)
      @partial_path = Pathname.new(p).realpath
    end
    alias :partials_path :partial_path
    alias :partials_path= :partial_path=
    
    def layouts_path=(p)
      @layouts_path = Pathname.new(p).realpath
    end
    
  end
end

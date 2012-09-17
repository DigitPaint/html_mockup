require 'rubygems'
require 'thor'

require 'pathname'
require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/project"
require File.dirname(__FILE__) + "/w3c_validator"

module HtmlMockup
  class Cli < Thor
    desc "serve [directory]","Serve directory as HTML, defaults to current directory"
    method_options :port => :string, # Defaults to 9000
                   :html_path => :string, # The document root, defaults to "[directory]/html"
                   :partial_path => :string, # Defaults to [directory]/partials
                   :handler => :string # The handler to use (defaults to mongrel)
    def serve(path=".")      
      # TODO: Deprecation warning for people used to older versions that had path relative to the HTML directory
      
      # Load the project, it should take care of all the paths
      @project = initialize_project(path, options)
      
      server = @project.server
      
      puts "Running HtmlMockup with #{server.handler.inspect} on port #{server.port}"
      puts banner(@project) 
      
      server.run!
    end
    
    desc "release [directory]", "Create a release for the project"
    def release(path=".")
      project = initialize_project(path, options)
      project.release.run!
    end
    
    desc "validate [directory/file]", "Validates the file or all HTML in directory"
    method_options :show_valid => :boolean, # Also print a line for each valid file
                   :filter => :string # What files should be found, defaults to [^_]*.html
    def validate(path=".")
      filter = options["filter"] || "[^_]*.html"
      
      puts "Filtering on #{options["filter"]}" if options["filter"]
      
      if File.directory?(path)
        any_invalid = false
        
        if (files = Dir.glob("#{path}/**/#{filter}")).any?
        	files.each do |file|
        		if !self.w3cvalidate(file)
        		  any_invalid = true
        	  end
        	end
        	if !any_invalid
        	  puts "All files were considered valid"
          end
        else
          puts "No files matched \"#{filter}\""
        end
      elsif File.readable?(path)
        self.w3cvalidate(path)
      else
        puts "No such file/directory #{path}"
      end      
    end
    
    desc "generate [directory]","Create a new HTML mockup directory tree in directory"
    def generate(path)
      path = Pathname.new(path)
      if path.directory?
        puts "Directory #{path} already exists, please only use this to create new mockups"
      else
        example_path = Pathname.new(File.dirname(__FILE__) + "/../../examples")
        path.mkpath
        html_path = path + "html"
        mkdir(html_path)
        mkdir(html_path + "stylesheets")
        mkdir(html_path + "images")
        mkdir(html_path + "javascripts")
        
        mkdir(path + "partials")
        
        mkdir(path + "script")
        cp(example_path + "script/server",path + "script/server")
        cp(example_path + "config.ru",path + "config.ru")        
        (path + "script/server").chmod(0755)
      end
    end
    
    desc "extract [source_path] [target_path]", "Extract a fully relative html mockup into target_path. It will expand all absolute href's, src's and action's into relative links if they are absolute"
    method_options :partial_path => :string, # Defaults to [directory]/partials
                   :filter => :string # What files should be converted defaults to **/*.html
    def extract(source_path=".", target_path="../out")
      project = initialize_project(source_path)
      extractor = HtmlMockup::Extractor.new(project, target_path)
      puts "Extracting mockup"
      puts banner(project)
      extractor.run!
    end
    
    protected
    
    def banner(project)
      puts "  Html: \"#{project.html_path}\""
      puts "  Partials: \"#{project.partial_path}\" (#{HtmlMockup::Template.partial_files(project.partial_path).size} found)"      
    end
    
    # TODO: handle options
    def initialize_project(path, options={})
      Project.new(path)
    end

    def w3cvalidate(file)
      validator = W3CValidator.new(File.read(file))
      validator.validate!  
      if !options["show_valid"] && !validator.valid || options["show_valid"]
        print "- #{file} "    
        print "(errors: #{validator.errors}, warnings: #{validator.warnings})\n"
      end
      validator.valid
    end
    
 
  end
end
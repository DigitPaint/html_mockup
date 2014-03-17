require 'rubygems'
require 'thor'
require 'thor/group'

require 'pathname'
require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/project"
require File.dirname(__FILE__) + "/generators"
require File.dirname(__FILE__) + "/w3c_validator"

if Object.const_defined?(:Bundler)
  Bundler.require(:default)
end


module HtmlMockup
  class Cli < Thor
    
    register Generators::Generate, "generate", "generate [COMMAND]", "Run a generator"

    class_option :verbose,
      :desc =>  "Set's verbose output",
      :aliases => ["-v"],
      :default => false,
      :type => :boolean
    

    desc "serve [directory]","Serve directory as HTML, defaults to current directory"
    method_options :port => :string, # Defaults to 9000
                   :html_path => :string, # The document root, defaults to "[directory]/html"
                   :partial_path => :string, # Defaults to [directory]/partials
                   :handler => :string, # The handler to use (defaults to mongrel)
                   :validate => :boolean # Run validation?

    def serve(path=".")
      
      server_options = {} 
      options.each{|k,v| server_options[k.to_sym] = v }
      server_options[:server] = {}
      [:port, :handler, :validate].each do |k|
        server_options[:server][k] = server_options.delete(k) if server_options.has_key?(k)
      end
      
      # Load the project, it should take care of all the paths
      @project = initialize_project(path, server_options)
      
      server = @project.server
      server.set_options(server_options[:server])
      
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
      puts "  Partials: \"#{project.partial_path}\""
    end
    
    # TODO: handle options
    def initialize_project(path, options={})
      
      if((Pathname.new(path) + "../partials").exist?)
        puts "[ERROR]: Don't use the \"html\" path, use the project base path instead"
        exit(1)
      end
      
      Project.new(path, {:shell => self.shell}.update(options))
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
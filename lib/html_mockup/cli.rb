require 'rubygems'
require 'thor'

require 'pathname'
require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/w3c_validator"

module HtmlMockup
  class Cli < Thor
    desc "serve [directory]","Serve directory as HTML, defaults to current directory"
    method_options :port => :optional, # Defaults to 9000
                   :partial_path => :optional, # Defaults to [directory]/../partials
                   :validate => :boolean # Automatically validate all HTML responses @ the w3c
    def serve(path=".")
      @path,@partial_path = template_paths(path,options["partial_path"])      
      require 'rack'
      require File.dirname(__FILE__) + "/rack/html_mockup"
      require File.dirname(__FILE__) + "/rack/html_validator"      
      chain = ::Rack::Builder.new do
        use ::Rack::ShowExceptions
        use ::Rack::Lint
      end
      chain.use Rack::HtmlValidator if options["validate"]
      chain.run Rack::HtmlMockup.new(@path, @partial_path)
      
      begin
        server = ::Rack::Handler::Mongrel
      rescue LoadError => e
        server = ::Rack::Handler::WEBrick
      end
      
      server_options = {}
      server_options[:Port] = options["port"] || "9000"
      
      puts "Running #{server.inspect} on port #{server_options[:Port]}"
      puts "  Taking partials from #{@partial_path} (#{HtmlMockup::Template.partial_files(@partial_path).size} found)"
      server.run chain.to_app, server_options
    end
    
    desc "validate [directory/file]", "Validates the file or all HTML in directory"
    method_options :show_valid => :boolean, # Also print a line for each valid file
                   :filter => :optional # What files should be found, defaults to [^_]*.html
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
        (path + "script/server").chmod(744)
      end
    end
    
    desc "convert [directory]","Inject all partials, into all HTML files within directory"
    method_options :partial_path => :optional, # Defaults to [directory]/../partials
                   :filter => :optional # What files should be converted defaults to *.html
    def convert(path=".")
      path,partial_path = template_paths(path,options["partial_path"])
      filter = options["filter"] || "*.html"      
      puts "Converting #{filter} in #{path}"
      puts "  Taking partials from #{partial_path} (#{HtmlMockup::Template.partial_files(partial_path).size} found)"
      
      if path.directory?
      	Dir.glob("#{path}/#{filter}").each do |file|
      		puts "  Converting file: " + file
          HtmlMockup::Template.open(file, :partial_path => partial_path).save
      	end
      else
        HtmlMockup::Template.open(path, :partial_path => partial_path).save
      end	
      
    end
    
    
    protected
    
    def template_paths(path,partial_path=nil)
      path = Pathname.new(path)
      partial_path = partial_path && Pathname.new(partial_path) || (path + "../partials/").realpath
      [path,partial_path]
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
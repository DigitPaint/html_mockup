require 'rubygems'

# Require bundler gems if available
if Object.const_defined?(:Bundler)
  Bundler.require(:default)
end


require 'thor'
require 'thor/group'

require 'pathname'
require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/project"
require File.dirname(__FILE__) + "/w3c_validator"


module HtmlMockup
  module Cli; end
end

require File.dirname(__FILE__) + "/cli/command"
require File.dirname(__FILE__) + "/cli/serve"
require File.dirname(__FILE__) + "/cli/release"
require File.dirname(__FILE__) + "/cli/generate"

require File.dirname(__FILE__) + "/generators"



module HtmlMockup
  class Cli::Base < Thor
    
    register Cli::Generate, "generate", "generate [COMMAND]", "Run a generator"

    register Cli::Serve, "serve", "serve #{Cli::Serve.arguments.map{ |arg| arg.banner }.join(" ")}", Cli::Serve.desc
    self.tasks["serve"].options = Cli::Serve.class_options

    register Cli::Release, "release", "release #{Cli::Release.arguments.map{ |arg| arg.banner }.join(" ")}", Cli::Release.desc
    self.tasks["release"].options = Cli::Release.class_options
    
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
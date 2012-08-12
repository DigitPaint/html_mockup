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
      require File.dirname(__FILE__) + '/server'
      
      # TODO: Deprecation warning for people used to older versions that had path relative to the HTML directory
      
      # Load the project, it should take care of all the paths
      @project = Project.new(path)
      
      # Override any Mockupfile settings with commandline options
      # TODO: Override any Mockupfile settings with commandline options
      
      server = @project.server
      
      puts "Running HtmlMockup with #{server.handler.inspect} on port #{server.port}"
      puts "  Serving: \"#{server.html_path}\""
      puts "  Partials: \"#{server.partial_path}\" (#{HtmlMockup::Template.partial_files(server.partial_path).size} found)"
      
      server.run!
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
    
    desc "convert [directory]","Inject all partials, into all HTML files within directory"
    method_options :partial_path => :string, # Defaults to [directory]/../partials
                   :filter => :string # What files should be converted defaults to **/*.html
    def convert(path=".")
      path,partial_path = template_paths(path,options["partial_path"])
      filter = options["filter"] || "**/*.html"      
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
    
    desc "extract [source_path] [target_path]", "Extract a fully relative html mockup into target_path. It will expand all absolute href's, src's and action's into relative links if they are absolute"
    method_options :partial_path => :string, # Defaults to [directory]/../partials
                   :filter => :string # What files should be converted defaults to **/*.html
    def extract(source_path=".",target_path="../out")
      require 'hpricot'
      source_path,target_path = Pathname.new(source_path),Pathname.new(target_path)
      source_path,partial_path = template_paths(source_path,options["partial_path"])
      filter = options["filter"] || "**/*.html"
      raise "Target #{target_path} already exists, please choose a new directory to extract into" if target_path.exist?
      
      mkdir_p(target_path)
      target_path = target_path.realpath
      
      # Copy source to target first, we'll overwrite the templates later on.
      cp_r(source_path.children,target_path)
      
      Dir.chdir(source_path) do
        Dir.glob(filter).each do |file_name|
          source = HtmlMockup::Template.open(file_name, :partial_path => partial_path).render
          cur_dir = Pathname.new(file_name).dirname
          up_to_root = File.join([".."] * (file_name.split("/").size - 1))
          doc = Hpricot(source)
          %w{src href action}.each do |attribute|
            (doc/"*[@#{attribute}]").each do |tag|
              url = tag[attribute]
              
              # Skip if the url doesn't start with a / (but not with //)
              next unless url =~ /\A\/[^\/]/
              
              # Strip off anchors
              anchor = nil
              url.gsub!(/(#.+)\Z/) do |r|
                anchor = r
                ""
              end
              
              # Strip of query strings
              query = nil
              url.gsub!(/(\?.+)\Z/) do |r|
                query = r
                ""
              end
              
              if true_file = resolve_path(cur_dir + up_to_root + url.sub(/\A\//,""))
                url = true_file.relative_path_from(cur_dir).to_s
                url += query if query
                url += anchor if anchor
                tag[attribute] = url
              else
                puts "Could not resolve link #{tag[attribute]} in #{file_name}"
              end
            end
          end

          File.open(target_path + file_name,"w"){|f| f.write(doc.to_original_html) }
        end
      end      
    end
    
    protected

    # TODO: remove this in favour of the project path
    def template_paths(path, partial_path=nil)
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
    
    def resolve_path(path)
      path = Pathname.new(path) unless path.kind_of?(Pathname)
      # Append index.html/index.htm/index.rhtml if it's a diretory
      if path.directory?
        search_files = %w{.html .htm}.map!{|p| path + "index#{p}" }
      # If it ends with a slash or does not contain a . and it's not a directory
      # try to add .html/.htm/.rhtml to see if that exists.
      elsif (path.to_s =~ /\/$/) || (path.to_s =~ /^[^.]+$/)
        search_files = [path.to_s + ".html", path.to_s + ".htm"].map!{|p| Pathname.new(p) }
      else
        search_files = [path]
      end
      search_files.find{|p| p.exist? }  
    end    
  end
end
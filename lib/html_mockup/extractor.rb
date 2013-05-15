require 'hpricot'
require File.dirname(__FILE__) + '/resolver'

module HtmlMockup
  
  # @deprecated Don't use the extractor anymore, use release.use(:mockup, options) processor and release.use(:url_relativizer, options) processor
  class Extractor
    
    attr_reader :project, :target_path
    
    
    # @param [Project] project Project object
    # @param [String,Pathname] target_path Path to extract to
    # @param [Hash] options Options hash
    
    # @option options [Array] :url_attributes The element attributes to parse and relativize
    # @option options [Array] :url_relativize Wether or not we should relativize
    # @option options [Array] :env ENV variable to pass to template renderer.
    def initialize(project, target_path, options={})
      @project = project
      @target_path = Pathname.new(target_path)
      @resolver = Resolver.new(self.target_path)
      
      
      @options = {
        :url_attributes => %w{src href action},
        :url_relativize => true,
        :env => {}
      }
      
      @options.update(options) if options
      
      @options[:env].update("MOCKUP_PROJECT" => project)
    end
    
    def run!
      target_path = self.target_path
      source_path = self.project.html_path
      
      
      filter = "**/*.html"
      raise ArgumentError, "Target #{target_path} already exists, please choose a new directory to extract into" if target_path.exist?
      
      mkdir_p(target_path)
      target_path = target_path.realpath
      
      # Copy source to target first, we'll overwrite the templates later on.
      cp_r(source_path.children, target_path)
      
      Dir.chdir(source_path) do
        Dir.glob(filter).each do |file_path|
          self.run_on_file!(file_path, @options[:env])
        end
      end           
    end
    
    def run_on_file!(file_path, env = {})
      source = self.extract_source_from_file(file_path, env)
      File.open(target_path + file_path,"w"){|f| f.write(source) }
    end
    
    # Runs the extractor on a single file and return processed source.
    def extract_source_from_file(file_path, env = {})
      source = HtmlMockup::Template.open(file_path, :partial_path => self.project.partial_path).render(env.dup)

      if @options[:url_relativize]
        source = relativize_urls(source, file_path)
      end
      
      source
    end
    
    
    protected
    
    def relativize_urls(source, file_path)
      doc = Hpricot(source)
      @options[:url_attributes].each do |attribute|
        (doc/"*[@#{attribute}]").each do |tag|
          converted_url = @resolver.url_to_relative_url(tag[attribute], file_path)
              
          case converted_url
          when String
            tag[attribute] = converted_url
          when nil
            puts "Could not resolve link #{tag[attribute]} in #{file_path}"
          end
        end
      end
      
      doc.to_original_html      
    end
            
  end
end
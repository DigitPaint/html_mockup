require 'tilt'
require 'yaml'
require 'ostruct'

require File.dirname(__FILE__) + "/mockup_template"

module HtmlMockup
  
  class Template
    
    # The source
    attr_accessor :source
    
    # Store the frontmatter
    attr_accessor :data
    
    # The actual Tilt template
    attr_accessor :template
    
    # The path to the source file for this template
    attr_accessor :source_path
    
    class << self
      def open(path, options = {})
        raise "Unknown file #{path}" unless File.exist?(path)
        self.new(File.read(path), options.update(:source_path => path))
      end      
    end
    
    
    # @option options [String,Pathname] :source_path The path to the source of the template being processed
    # @option options [String,Pathname] :layouts_path The path to where all layouts reside
    # @option options [String,Pathname] :partials_path The path to where all partials reside    
    def initialize(source, options = {})
      @options = options
      self.source_path = options[:source_path]
      self.data, self.source = extract_front_matter(source)
      self.template = Tilt.new(self.source_path.to_s){ self.source }
      
      if self.data[:layout] && layout_template_path = self.find_template(self.data[:layout], :layouts_path)
        @layout_template = Tilt.new(layout_template_path.to_s)
      end
    end
    
    def render(env = {})
      context = TemplateContext.new(self)
      locals = {:document => OpenStruct.new(self.data)}

      if @layout_template
        @layout_template.render(context, locals) do
          self.template.render(context, locals)
        end
      else
        self.template.render(context, locals)
      end
    end
    
    def find_template(name, path_type)
      raise(ArgumentError, "path_type must be one of :partials_path or :layouts_path") unless [:partials_path, :layouts_path].include?(path_type)

      @resolvers ||= {}        
      @resolvers[path_type] ||= Resolver.new(@options[path_type])
      
      @resolvers[path_type].url_to_path(name)
    end      
    
    protected
    
    # Get the front matter portion of the file and extract it.
    def extract_front_matter(source)
      fm_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      
      if match = source.match(fm_regex)
        source = source.sub(fm_regex, "")

        begin
          data = (YAML.load(match[1]) || {}).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        rescue *YAML_ERRORS => e
          puts "YAML Exception: #{e.message}"
          return false
        end
      else
        return [{}, source]
      end

      [data, source]
    rescue
      [{}, source]
    end
    
  end
  
  class TemplateContext
    
    def initialize(template)
      @_template = template
    end
    
    def template
      @_template
    end
    
    def env
      # TODO
      {}
    end
    
    def partial(name, options = {})
      template_path = self.template.find_template(name, :partials_path)
      puts "Calling partial #{name}, with template #{template_path}"      
      if template_path
        partial_template = Tilt.new(template_path.to_s)
        partial_template.render(self, options[:locals] || {})
      else
        raise ArgumentError, "No such partial #{name}"
      end
    end
    
  end
  
end
require 'pathname'
require 'strscan'
require 'erb'
require 'cgi'
require 'tilt'

module HtmlMockup
  
  class MissingPartial < StandardError; end
  
  class Template
  
    class << self
      def open(filename,options={})
        raise "Unknown file #{filename}" unless File.exist?(filename)
        self.new(File.read(filename),options.update(:target_file => filename))
      end
      
      # Returns all available partials in path
      def partials(path)
        available_partials = {}
        path = Pathname.new(path)
        self.partial_files(path).inject({}) do |mem,f|
          name = f.to_s.split(".",2)[0]
          mem[name] = (path + f).read
          mem
        end
      end
      
      def partial_files(path)
        filter = "**/*.part.{?h,h}tml"
        files = []
        Dir.chdir(Pathname.new(path)) do 
          files = Dir.glob(filter)        
        end
        files
      end
      
    end
  
    # Create a new HtmlMockupTemplate
    #
    # ==== Parameters
    # template<String>:: The template to parse
    # options<Hash>:: See options
    #
    # ==== Options (optional)
    # partial_path<String>:: Path where the partials reside (default: $0/../../partials)
    #--
    def initialize(template, options={})
      defaults = {:partial_path => File.dirname(__FILE__) + "/../../partials/"}
      @template = template
      @options = defaults.update(options)
      @scanner = StringScanner.new(@template)
      raise "Partial path '#{self.options[:partial_path]}' not found" unless File.exist?(self.options[:partial_path])
    end
  
    attr_reader :template, :options, :scanner
  
    # Renders the template and returns it as a string
    #
    # ==== Parameters
    # env<Hash>:: An environment hash (mostly used in combination with Rack)
    #
    # ==== Returns
    # String:: The rendered template
    #--
    def render(env={})
      out = ""
    	while (partial = self.parse_partial_tag!) do
    	  tag,params,scanned = partial
    		# add new skipped content to output file
    		out << scanned

    		# scan until end of tag
    		current_content = self.scanner.scan_until(/<!-- \[STOP:#{tag}\] -->/)
    		out << (render_partial(tag, params, env) || current_content)
    	end
    	out << scanner.rest    
    end
  
    def save(filename=self.options[:target_file])
      File.open(filename,"w"){|f| f.write render}
    end
  
    protected
  
    def available_partials(force=false)
      return @_available_partials if @_available_partials && !force
      @_available_partials = self.class.partials(self.options[:partial_path])
    end
  
    def parse_partial_tag!
      params = {}
      scanned = ""
      begin_of_tag = self.scanner.scan_until(/<!-- \[START:/)
      return nil unless begin_of_tag
      scanned << begin_of_tag
      scanned << tag = self.scanner.scan(/[a-z0-9_\/\-]+/)
      if scanned_questionmark = self.scanner.scan(/\?/)
        scanned << scanned_questionmark
        scanned << raw_params = self.scanner.scan_until(/\] -->/)
        raw_params.gsub!(/\] -->$/,"")
      
        params = CGI.parse(raw_params)
        params.keys.each{|k| params[k] = params[k].first }
      else
        scanned << self.scanner.scan_until(/\] -->/)
      end

      [tag,params,scanned]
    end
  
    # Actually renders the tag as ERB
    def render_partial(tag, params, env = {})
      unless self.available_partials[tag]
        raise MissingPartial.new("Could not find partial '#{tag}' in partial path '#{@options[:partial_path]}'")
      end
      template = Tilt::ERBTemplate.new{ self.available_partials[tag] }
      context = TemplateContext.new(params)
      "\n" + template.render(context, :env => env).rstrip + "\n<!-- [STOP:#{tag}] -->"
    end
  
    class TemplateContext
      # Params will be set as instance variables
      def initialize(params)
        params.each do |k,v|
          self.instance_variable_set("@#{k}",v)
        end
      end      
    end
  
  end
end
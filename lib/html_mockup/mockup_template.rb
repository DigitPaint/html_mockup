require 'tilt'
require 'strscan'
require 'cgi'
require 'tilt/template'

module HtmlMockup

  class MockupTemplate < Tilt::Template
    
    
    class MissingPartial < StandardError; end
    
    
    self.default_mime_type = 'text/html'
    
    attr_reader :scanner
    
    def self.engine_initialized?
      true
    end
    
    def prepare
      
    end
    
    def evaluate(scope, locals, &block)
      @scanner = StringScanner.new(data)      
      out = ""
      while (partial = self.parse_partial_tag!) do
        name, params, scanned = partial
        # add new skipped content to output file
        out << scanned

        # scan until end of tag
        current_content = self.scanner.scan_until(/<!-- \[STOP:#{name}\] -->/)
        out << (render_partial(name, params, scope) || current_content)
      end
      out << scanner.rest  

      @output = out
    end
    
    protected
    
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
    
    def render_partial(name, params, scope)
      if partial_template_path = scope.template.find_template(name, :partials_path)
        # New style templates
        out = (scope.partial(name, :locals => params) || current_content)
      elsif partial_template_path = scope.template.find_template(name.to_s + ".part", :partials_path)
        # Old style templates
        template = Tilt::ERBTemplate.new(partial_template_path.to_s)
        context = TemplateContext.new(params)
        out = template.render(context, :env => scope.env)
      else
        # Not found        
        raise MissingPartial.new("Could not find partial '#{name}'")
      end
      
      "\n" + out.rstrip + "\n<!-- [STOP:#{name}] -->"
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

Tilt.register HtmlMockup::MockupTemplate, "html"
Tilt.prefer HtmlMockup::MockupTemplate
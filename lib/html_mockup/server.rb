require 'rack'
require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/w3c_validator"
require File.dirname(__FILE__) + "/rack/html_mockup"
require File.dirname(__FILE__) + "/rack/html_validator"      

module HtmlMockup
  class Server
    
    attr_reader :options
    
    attr_accessor :html_path, :partial_path
    
    attr_accessor :port, :handler
    
    def initialize(html_path, partial_path, options={})
      @stack = ::Rack::Builder.new 
      @stack.use ::Rack::ShowExceptions
      @stack.use ::Rack::Lint
      @stack.use ::Rack::ConditionalGet
      @stack.use ::Rack::Head 

      @middleware = []
      @html_path = html_path
      @partial_path = partial_path
      @options = {
        :handler => nil, # Autodetect
        :port => 9000
      }.update(options)
      
      @port = @options[:port]
      @handler = @options[:handler]
    end
        
    # Use the specified Rack middleware
    def use(*args, &block)
      @stack.use *args, &block
    end
    
    # Use the map handler to map endpoints to certain urls
    def map(*args, &block)
      @stack.map *args, &block
    end
    
    def handler
      if self.options[:handler]
        begin
          @handler = ::Rack::Handler.get(self.handler)
        rescue LoadError
        rescue NameError
        end
        if @handler.nil?
          puts "Handler '#{self.options[:handler]}' not found, using fallback."
        end        
      end
      @handler ||= detect_rack_handler
    end
        
    def run!
      self.handler.run self.application, self.server_options do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "Bby HtmlMockup"
        end
      end
    end
    alias :run :run!
    
    def application
      return @app if @app
      
      @stack.use Rack::HtmlValidator if self.options["validate"]
      @stack.run Rack::HtmlMockup.new(self.html_path, self.partial_path)
      
      @app = @stack
    end

    
    protected
    
    # Generate server options for handler
    def server_options
      {
        :Port => self.port
      }
    end
    
    
    # Sinatra's detect_rack_handler
    def detect_rack_handler
      servers = %w[mongrel thin webrick]
      servers.each do |server_name|
        begin
          return ::Rack::Handler.get(server_name)
        rescue LoadError
        rescue NameError
        end
      end
      raise "Server handler (#{servers.join(',')}) not found."
    end    
    
  end
end
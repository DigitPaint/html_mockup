require 'rack'
require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/w3c_validator"
require File.dirname(__FILE__) + "/rack/html_mockup"
require File.dirname(__FILE__) + "/rack/html_validator"      

module HtmlMockup
  class Server
    attr_accessor :options,:server_options, :root, :partial_path
    
    def initialize(root,partial_path,options={},server_options={})
      @stack = ::Rack::Builder.new 

      @middleware = []
      @root = root
      @partial_path = partial_path
      @options,@server_options = options,server_options
    end
    
    # Use the specified Rack middleware
    def use(middleware, *args, &block)
      @middleware << [middleware, args, block]
    end
    
    def handler
      @handler ||= detect_rack_handler      
    end
    
    def run
      self.handler.run self.application, @server_options do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "Bby HtmlMockup"
        end
      end
    end
    
    def application
      return @app if @app
      @stack.use ::Rack::ShowExceptions
      @stack.use ::Rack::Lint
      
      @middleware.each { |c,a,b| builder.use(c, *a, &b) }
      
      @stack.use Rack::HtmlValidator if self.options["validate"]
      @stack.run Rack::HtmlMockup.new(self.root, self.partial_path)
      
      @app = @stack.to_app
    end

    
    protected
    
    # Sinatra's detect_rack_handler
    def detect_rack_handler
      servers = %w[thin mongrel webrick]
      servers.each do |server_name|
        begin
          return ::Rack::Handler.get(server_name.capitalize)
        rescue LoadError
        rescue NameError
        end
      end
      raise "Server handler (#{servers.join(',')}) not found."
    end    
    
  end
end
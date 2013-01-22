require 'rack/request'
require 'rack/response'
require 'rack/file'

require File.dirname(__FILE__) + '/../resolver'

module HtmlMockup
  module Rack
    
    class HtmlMockup
      
      attr_reader :project
      
      def initialize(project)
        @project = project
        root,partial_path = project.html_path, project.partial_path
        
        @docroot = root
        @partial_path = partial_path
        @file_server = ::Rack::File.new(@docroot)
      end

      def call(env)
        url = env["PATH_INFO"]
        env["MOCKUP_PROJECT"] = project
        
        resolver = Resolver.new(@docroot)

        if template_path = resolver.url_to_path(url)
          env["rack.errors"].puts "Rendering template #{template_path.inspect} (#{url.inspect})"
          begin
            templ = ::HtmlMockup::Template.open(template_path, :partial_path => @partial_path)
            resp = ::Rack::Response.new do |res|
              res.status = 200
              res.write templ.render(env)
            end
            resp.finish
          rescue StandardError => e
            env["rack.errors"].puts "  #{e.message}"
            resp = ::Rack::Response.new do |res|
              res.status = 500
              res.write "An error occurred"
            end
            resp.finish
          end
        else
          env["rack.errors"].puts "Invoking file handler for #{url.inspect}"
          @file_server.call(env)
        end
      end    
    end
  end
end
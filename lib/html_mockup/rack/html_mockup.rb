require 'rack/request'
require 'rack/response'
require 'rack/file'

module HtmlMockup
  module Rack
    class HtmlMockup
      def initialize(root,partial_path)
        @docroot = root
        @partial_path = partial_path
        @file_server = ::Rack::File.new(@docroot)
      end

      def call(env)
        path = env["PATH_INFO"]
        
        # TODO: Combine with Extractor#resolve_path
        
        # Append index.html/index.htm if it's a diretory
        if File.directory?(File.join(@docroot,path))
          search_files = %w{.html .htm}.map!{|p| File.join(@docroot,path,"index#{p}")}
        # If it's already a .html/.htm file, render that file
        elsif (path =~ /\.html?$/)
          search_files = [File.join(@docroot,path)]
        # If it ends with a slash or does not contain a . and it's not a directory
        # try to add .html/.htm to see if that exists.
        elsif (path =~ /\/$/) || (path =~ /^[^.]+$/)
          search_files = [path + ".html", path + ".htm"].map!{|p| File.join(@docroot,p) }
        # Otherwise don't render anything at all.
        else
          search_files = []
        end

        if template_path = search_files.find{|p| File.exist?(p)}
          env["rack.errors"].puts "Rendering template #{template_path.inspect} (#{path.inspect})"
          begin
            templ = ::HtmlMockup::Template.open(template_path, :partial_path => @partial_path)
            resp = ::Rack::Response.new do |res|
              res.status = 200
              res.write templ.render
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
          env["rack.errors"].puts "Invoking file handler for #{path.inspect}"
          @file_server.call(env)
        end
      end    
    end
  end
end
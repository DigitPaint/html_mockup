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
        
        # Append index.html/index.htm/index.rhtml if it's a diretory
        if File.directory?(File.join(@docroot,path))
          search_files = %w{.html .htm .rhtml}.map!{|p| File.join(@docroot,path,"index#{p}")}
        # If it's already a .html/.htm/.rhtml file, render that file
        elsif (path =~ /\.r?html?$/)
          search_files = [File.join(@docroot,path)]
        # If it ends with a slash or does not contain a . and it's not a directory
        # try to add .html/.htm/.rhtml to see if that exists.
        elsif (path =~ /\/$/) || (path =~ /^[^.]+$/)
          search_files = [path + ".html", path + ".htm", path + ".rhtml"].map!{|p| File.join(@docroot,p) }
        # Otherwise don't render anything at all.
        else
          search_files = []
        end

        if template_path = search_files.find{|p| File.exist?(p)}
          env["rack.errors"].puts "Rendering template #{template_path.inspect} (#{path.inspect})"
          templ = ::HtmlMockup::Template.open(template_path, :partial_path => @partial_path)
          resp = ::Rack::Response.new do |res|
            res.status = 200
            res.write templ.render
          end
          resp.finish
        else
          env["rack.errors"].puts "Invoking file handler for #{path.inspect}"
          @file_server.call(env)
        end
      end    
    end
  end
end
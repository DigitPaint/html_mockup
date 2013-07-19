module HtmlMockup
  class Resolver
    
    def initialize(path)
      raise ArgumentError, "Resolver base path can't be nil" if path.nil?
      @base = Pathname.new(path)
    end
    
    # @param [String] url The url to resolve to a path
    # @param [true,false] exact_match Wether or not to match exact paths, this is mainly used in the path_to_url method to match .js, .css, etc files.
    def find_template(url, exact_match = false)
      path, qs, anch = strip_query_string_and_anchor(url.to_s)
      
      path = File.join(@base, path)
  
      if exact_match && File.exist?(path)
        return Pathname.new(path)
      end
      
      # It's a directory, add "/index"
      if File.directory?(path)
        path = File.join(path, "index")
      end
      
      # 2. If it's .html,we strip of the extension
      if path =~ /\.html\Z/
        path.sub!(/\.html\Z/, "")
      end
      
      extensions = Tilt.mappings.keys + Tilt.mappings.keys.map{|ext| "html.#{ext}"}

      if found_extension = extensions.find { |ext| File.exist?(path + "." + ext) }
        Pathname.new(path + "." + found_extension)
      end
    end
    alias :url_to_path :find_template
    
    
    # Convert a disk path on file to an url
    def path_to_url(path, relative_to = nil)

      path = Pathname.new(path).relative_path_from(@base).cleanpath
      
      if relative_to
        if relative_to.to_s =~ /\A\//
          relative_to = Pathname.new(File.dirname(relative_to.to_s)).relative_path_from(@base).cleanpath
        else
          relative_to = Pathname.new(File.dirname(relative_to.to_s))
        end
        path = Pathname.new("/" + path.to_s).relative_path_from(Pathname.new("/" + relative_to.to_s))
        path.to_s
      else
        "/" + path.to_s
      end
      
    end
    
    def url_to_relative_url(url, relative_to_path)
      # Skip if the url doesn't start with a / (but not with //)
      return false unless url =~ /\A\/[^\/]/
      
      path, qs, anch = strip_query_string_and_anchor(url)

      # Get disk path
      if true_path =  self.url_to_path(path, true)
        path = self.path_to_url(true_path, relative_to_path)
        path += qs if qs
        path += anch if anch
        path
      else
        false
      end
    end
    
    def strip_query_string_and_anchor(url)
      url = url.dup
      
      # Strip off anchors
      anchor = nil
      url.gsub!(/(#.+)\Z/) do |r|
        anchor = r
        ""
      end
              
      # Strip off query strings
      query = nil
      url.gsub!(/(\?.+)\Z/) do |r|
        query = r
        ""
      end
      
      [url, query, anchor]
    end  
    
  end
end

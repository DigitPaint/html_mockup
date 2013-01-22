module HtmlMockup
  class Resolver
    
    def initialize(path)
      @base = Pathname.new(path)
    end
    
    def url_to_path(url, exact_match = false)
      path, qs, anch = strip_query_string_and_anchor(url.to_s)
      
      extensions = %w{html htm}
        
      # Append index.extension if it's a diretory
      if File.directory?(File.join(@base,path))
        search_files = extensions.map{|p| File.join(@base,path,"index.#{p}")}
      # If it's already a .extension file, return that file
      elsif extensions.detect{|e| path =~ /\.#{e}\Z/ }
        search_files = [File.join(@base,path)]
      # If it ends with a slash or does not contain a . and it's not a directory
      # try to add extenstions to see if that exists.
      elsif (path =~ /\/$/) || (path =~ /^[^.]+$/)
        search_files = extensions.map{|e| File.join(@base,"#{path}.#{e}") }
      # Otherwise don't return anything at all.
      else
        if exact_match
          search_files = [File.join(@base,path)]
        else
          search_files = []
        end
      end
      
      if file = search_files.find{|p| File.exist?(p) }
        Pathname.new(file)
      end
    end
    
    
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

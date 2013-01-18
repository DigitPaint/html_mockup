require 'hpricot'

module HtmlMockup
  class Extractor
    
    attr_reader :project, :target_path
    
    
    # @param [Project] project Project object
    # @param [String,Pathname] target_path Path to extract to
    # @param [Hash] options Options hash
    
    # @option options [Array] :url_attributes The element attributes to parse and relativize
    # @option options [Array] :url_relativize Wether or not we should relativize
    # @option options [Array] :env ENV variable to pass to template renderer.
    def initialize(project, target_path, options={})
      @project = project
      @target_path = Pathname.new(target_path)
      
      @options = {
        :url_attributes => %w{src href action},
        :url_relativize => true,
        :env => {}
      }
      
      @options.update(options) if options
    end
    
    def run!
      target_path = self.target_path
      source_path = self.project.html_path
      
      
      filter = "**/*.html"
      raise ArgumentError, "Target #{target_path} already exists, please choose a new directory to extract into" if target_path.exist?
      
      mkdir_p(target_path)
      target_path = target_path.realpath
      
      # Copy source to target first, we'll overwrite the templates later on.
      cp_r(source_path.children, target_path)
      
      Dir.chdir(source_path) do
        Dir.glob(filter).each do |file_path|
          self.run_on_file!(file_path, @options[:env])
        end
      end           
    end
    
    def run_on_file!(file_path, env = {})
      source = self.extract_source_from_file(file_path, env)
      File.open(target_path + file_path,"w"){|f| f.write(source) }      
    end
    
    # Runs the extractor on a single file
    def extract_source_from_file(file_path, env = {})
      source = HtmlMockup::Template.open(file_path, :partial_path => self.project.partial_path).render(env)
          
      if @options[:url_relativize]
        source = relativize_urls(source, file_path)
      end

      source
    end

    
    protected
    
    def relativize_urls(source, file_name)
      cur_dir = Pathname.new(file_name).dirname
      puts file_name.to_s.split("/").inspect
      up_to_root = File.join([".."] * (file_name.to_s.split("/").size - 1))
          
      doc = Hpricot(source)
      @options[:url_attributes].each do |attribute|
        (doc/"*[@#{attribute}]").each do |tag|
          converted_url = convert_relative_url_to_absolute_url(tag[attribute], cur_dir,  up_to_root)
              
          case converted_url
          when String
            tag[attribute] = converted_url
          when nil
            puts "Could not resolve link #{tag[attribute]} in #{file_name}"
          end
        end
      end
      
      doc.to_original_html      
    end
    
    # @return [false, nil, String] False if it can't be converted, nil if it can't be resolved and the converted string if it can be resolved.
    def convert_relative_url_to_absolute_url(url, cur_dir, up_to_root)
      # Skip if the url doesn't start with a / (but not with //)
      return false unless url =~ /\A\/[^\/]/
              
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
              
      if true_file = resolve_path(cur_dir + up_to_root + url.sub(/\A\//,""))
        url = true_file.relative_path_from(cur_dir).to_s
        url += query if query
        url += anchor if anchor
        url
      else
        nil
      end
      
    end
    
    def resolve_path(path)
      path = Pathname.new(path) unless path.kind_of?(Pathname)
      # Append index.html/index.htm/index.rhtml if it's a diretory
      if path.directory?
        search_files = %w{.html .htm}.map!{|p| path + "index#{p}" }
      # If it ends with a slash or does not contain a . and it's not a directory
      # try to add .html/.htm to see if that exists.
      elsif (path.to_s =~ /\/$/) || (path.to_s =~ /^[^.]+$/)
        search_files = [path.to_s + ".html", path.to_s + ".htm"].map!{|p| Pathname.new(p) }
      else
        search_files = [path]
      end
      search_files.find{|p| p.exist? }  
    end   
        
  end
end
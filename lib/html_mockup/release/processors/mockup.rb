module HtmlMockup::Release::Processors
  class Mockup < Base
    
    attr_accessor :project
    
    def initialize(options={})
      @options = {
        :env => {},
        :match => ["**/*.{html,md,html.erb}"],
        :skip => [/\Astylesheets/, /\Ajavascripts/]
      }
      
      @options.update(options) if options            
    end

    def call(release, options={})
      self.project = release.project
      
      options = {}.update(@options).update(options)
      
      options[:env].update("MOCKUP_PROJECT" => project)
      
      release.log(self, "Processing mockup files")
      
      release.log(self, "  Matching: #{options[:match].inspect}", true)      
      release.log(self, "  Skiping : #{options[:skip].inspect}", true)            
      release.log(self, "  Env     : #{options[:env].inspect}", true)
      release.log(self, "  Files   :", true)
      
      release.get_files(options[:match], options[:skip]).each do |file_path|
        self.run_on_file!(file_path, @options[:env])
        release.log(self, "    Extract: #{file_path}", true)
      end
    end
    
    
    def run_on_file!(file_path, env = {})
      template = HtmlMockup::Template.open(file_path, :partials_path => self.project.partial_path, :layouts_path => self.project.layouts_path)
      
      # Clean up source file
      FileUtils.rm(file_path)
      
      # Write out new file
      File.open(self.target_path(file_path, template),"w"){|f| f.write(template.render(env.dup)) }
    end
    
    # Runs the extractor on a single file and return processed source.
    def extract_source_from_file(file_path, env = {})
      HtmlMockup::Template.open(file_path, :partials_path => self.project.partial_path, :layouts_path => self.project.layouts_path).render(env.dup)
    end    
    
    protected
    
    def target_path(path, template)
      # 1. If we have a double extension we rip of the template it's own extension and be done with it
      parts = File.basename(path.to_s).split(".")
      dir = Pathname.new(File.dirname(path.to_s))
      
      # 2. Try to figure out the extension based on the template's mime-type
      mime_types = {
        "text/html" => "html",
        "text/css"  => "css",
        "application/javascript" => "js",
        "text/xml" => "xml",
        "application/xml" => "xml",
        "text/csv" => "csv",
        "application/json" => "json"
      }
      extension = mime_types[template.template.class.default_mime_type]
      
      # Always return .html directly as it will cause too much trouble otherwise
      if parts.last == "html"
        return path
      end
      
      if parts.size > 2
        # Strip extension
        dir + parts[0..-2].join(".")
      else
        return path if extension.nil?
        
        if parts.size > 1
          # Strip extension and replace with extension
          dir + (parts[0..-2] << extension).join(".")
        else
          # Let's just add the extension
          dir + (parts << extension).join(".")
        end
      end
    end    
    
  end
end

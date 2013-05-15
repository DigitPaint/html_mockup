module HtmlMockup::Release::Processors
  class Mockup < Base
    
    attr_accessor :project
    
    def initialize(options={})
      @options = {
        :env => {},
        :match => ["**/*.html"]
      }
      
      @options.update(options) if options            
    end

    def call(release, options={})
      self.project = release.project
      
      options = {}.update(@options).update(options)
      
      options[:env].update("MOCKUP_PROJECT" => project)
      
      release.log(self, "Processing mockup files")
      
      release.get_files(options[:match]).each do |file_path|
        self.run_on_file!(file_path, @options[:env])
      end
    end
    
    
    def run_on_file!(file_path, env = {})
      source = self.extract_source_from_file(file_path, env)
      File.open(file_path,"w"){|f| f.write(source) }
    end
    
    # Runs the extractor on a single file and return processed source.
    def extract_source_from_file(file_path, env = {})
      HtmlMockup::Template.open(file_path, :partial_path => self.project.partial_path).render(env.dup)
    end    
    
  end
end

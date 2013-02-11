module HtmlMockup::Release::Finalizers
  
  class Zip < Base
    
    attr_reader :release
    
    # @option options :prefix Prefix to put before the version (default = "html")
    # @option options :zip The zip command
    def call(release, options = {})
      if options
        options = @options.dup.update(options)
      else
        options = @options
      end
      
      options = {
        :zip => "zip",
        :prefix => "html"
      }.update(options)

      name = [options[:prefix], release.scm.version].join("-") + ".zip"
      release.log(self, "Finalizing release to #{release.target_path + name}")
      
      if File.exist?(release.target_path + name)
        release.log(self, "Removing existing target #{release.target_path + name}")
        FileUtils.rm_rf(release.target_path + name)
      end
      
      begin
        `#{options[:zip]} -v`
      rescue Errno::ENOENT
        raise RuntimeError, "Could not find zip in #{options[:zip].inspect}"
      end

      ::Dir.chdir(release.build_path) do
        `zip -r -9 "#{release.target_path + name}" ./*`
      end
    end
    
 
  end
end
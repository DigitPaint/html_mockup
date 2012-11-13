require 'fileutils'

# Finalizes the release into a directory in target_path
# 
# The directory name will have the format PREFIX-VERSION
#
module HtmlMockup::Release::Finalizers
  class Dir < Base
    def initialize(options = {})
      @options = options
    end
    
    # @option options :prefix Prefix to put before the version (default = "html")
    def call(release, options = {})
      @options.update(options)

      name = [(@options[:prefix] || "html"), release.scm.version].join("-")      
      release.log(self, "Finalizing release to #{release.target_path + name}")
      
      if File.exist?(release.target_path + name)
        release.log(self, "Removing existing target #{release.target_path + name}")
        FileUtils.rm_rf(release.target_path + name)
      end
      
      FileUtils.cp_r release.build_path, release.target_path + name
    end
  end
end

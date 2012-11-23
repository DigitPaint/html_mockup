require 'fileutils'

# Finalizes the release into a directory in target_path
# 
# The directory name will have the format PREFIX-VERSION
#
module HtmlMockup::Release::Finalizers
  class Dir < Base    
    # @option options :prefix Prefix to put before the version (default = "html")
    def call(release, options = {})
      if options
        options = @options.dup.update(options)
      else
        options = @options
      end

      name = [(options[:prefix] || "html"), release.scm.version].join("-")      
      release.log(self, "Finalizing release to #{release.target_path + name}")
      
      if File.exist?(release.target_path + name)
        release.log(self, "Removing existing target #{release.target_path + name}")
        FileUtils.rm_rf(release.target_path + name)
      end
      
      FileUtils.cp_r release.build_path, release.target_path + name
    end
  end
end

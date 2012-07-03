require 'fileutils'

# Finalizes the release into a directory in target_path
# 
# The directory name will have the format PREFIX-VERSION
#
module HtmlMockup::Release::Finalizers
  class Dir < Base
    
    # @option options :prefix Prefix to put before the version (default = "html")
    def call(release, options = {})
      name = [(options[:prefix] || "html"), release.scm.version].join("-")
      
      release.log(self, "Finalizing release to #{release.target_path + name}")
      FileUtils.cp_r release.build_path, release.target_path + name
    end
  end
end

module HtmlMockup
  class Release::Cleaner
    def initialize(pattern)
      @pattern = pattern
    end
    
    def call(release, options = {})
      # We switch to the build path and append the globbed files for safety, so even if you manage to sneak in a
      # pattern like "/**/*" it won't do you any good as it will be reappended to the path
      Dir.chdir(release.build_path.to_s) do
        Dir.glob(@pattern).each do |file|
          path = File.join(release.build_path.to_s, file)
          if is_inside_build_path(release.build_path, path)
            release.log(self, "Cleaning up \"#{path}\" in build")
            rm_rf(path)
          else
            release.log(self, "FAILED cleaning up \"#{path}\" in build")
          end
        end
      end
    end

    protected

    def is_inside_build_path(build_path, path)     
      
      begin 
        build_path = Pathname.new(build_path).realpath.to_s
        path = Pathname.new(path)
        if(path.absolute?)
          path = path.realpath.to_s
        else
          path = Pathname.new(File.join(build_path.to_s, path)).realpath.to_s
        end
      rescue Errno::ENOENT
        # Real path does not exist
        return false
      end
      
      if path[build_path]
        return true
      else
        raise RuntimeError, "Cleaning pattern is not inside build directory"
      end
    end
  end
end
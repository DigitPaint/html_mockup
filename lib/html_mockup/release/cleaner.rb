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
          release.log(self, "Cleaning up \"#{path}\" in build")
          if inside_build_path release.build_path, path
              rm_rf(path)
          end
        end
      end
    end

    protected

    def inside_build_path(build_path, pattern)
      build_path = Pathname.new(build_path).realpath.to_s
      path = Pathname.new(File.join(build_path.to_s, pattern)).realpath.to_s
      if path[build_path]
        return true
      else
        raise RuntimeError, "Cleaning pattern is not inside build directory"
      end
    end
  end
end
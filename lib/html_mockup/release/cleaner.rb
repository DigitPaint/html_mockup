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
          rm(path)
        end
      end
    end
  end
end
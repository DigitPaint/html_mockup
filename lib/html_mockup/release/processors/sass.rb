# Use the sass gem
require 'sass'

module HtmlMockup::Release::Processors
  class Sass < Base
    # @param [Hash] options Options as described below, all other options will be passed to Sass.compile_file.
    #
    # @option options [Array] :match An array of shell globs, defaults to ["stylesheets/**/*.scss"]
    # @option options [Array] :skip An array of regexps which will be skipped, defaults to [/_.*\.scss\Z/], Attention! Skipped files will be deleted as well!
    def call(release, options={})
      options = {
        :match => ["stylesheets/**/*.scss"],
        :skip => [/_.*\.scss\Z/],
        :style => :expanded
      }.update(options)
      
      match = options.delete(:match)
      skip = options.delete(:skip)
      
      # Sassify SCSS files
      files = release.get_files(match)
      files.each do |f|
        puts "processing: #{f}"
        if !skip.detect{|r| r.match(f) }
          # Compile SCSS
          ::Sass.compile_file(f, f.gsub(/\.scss$/, ".css"), options)
        end        
      end
      
      # Cleanup
      files.each do |f|
        # Remove source file
        File.unlink(f)
      end
      
    end
  end
end

# Use the sass gem
require 'sass'

module HtmlMockup::Release::Processors
  class Sass < Base
    
    #  Create new Sass processor
    #
    # @param [Hash] options Options as described below, all other options will be passed to Sass.compile_file.
    #   @option options [Array] :match An array of shell globs, defaults to ["stylesheets/**/*.scss"]
    #   @option options [Array] :skip An array of regexps which will be skipped, defaults to [/_.*\.scss\Z/], Attention! Skipped files will be deleted as well!

    def initialize(options = {})
      @options = {
        :match => ["stylesheets/**/*.scss"],
        :skip => [/_.*\.scss\Z/],
        :style => :expanded
      }.update(options)
    end
    
    #  Run Sass processor
    # @param [Release] release Used to define the output paths
    # @param [Hash] options Options (see initialize)
    def call(release, options={})
      @options.update(options)

      match = @options.delete(:match)
      skip = @options.delete(:skip)
      
      # Sassify SCSS files
      files = release.get_files(match)
      files.each do |f|
        if !skip.detect{|r| r.match(f) }
          release.log(self, "Processing: #{f}")          
          # Compile SCSS
          ::Sass.compile_file(f, f.gsub(/\.scss$/, ".css"), @options)
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

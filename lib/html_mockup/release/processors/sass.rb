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
        :skip => [/\/_.*\.scss\Z/],
        :style => :expanded
      }.update(options)
      
      match = options.delete(:match)
      skip = options.delete(:skip)
      
      unless options.has_key?(:load_paths)
        if ::Sass::Plugin.options[:template_location].kind_of?(Hash)
          options[:load_paths] = ::Sass::Plugin.template_location_array.map{|k,v| k }
        else
          options[:load_paths] = [(release.build_path + "stylesheets").to_s]
        end
      end
      
      # Sassify SCSS files
      files = release.get_files(match)
      files.each do |f|
        if !skip.detect{|r| r.match(f) }
          release.log(self, "Processing: #{f}")          
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

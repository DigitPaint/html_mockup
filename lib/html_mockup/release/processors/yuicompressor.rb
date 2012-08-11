# Use the ruby-yui-compressor gem.
require 'yui/compressor'

module HtmlMockup::Release::Processors
  class Yuicompressor < Base
    
    # Compresses all JS and CSS files, it will keep all lines before
    # 
    #     /* -------------------------------------------------------------------------------- */
    # 
    # (80 dashes)
    #
    # @options options [Array] match Files to match, default to ["**/*.{css,js}"]
    # @options options [Regexp] :delimiter An array of header delimiters. Defaults to the one above. The delimiter will be removed from the output.
    # @options options [Array[Regexp]] :skip An array of file regular expressions to specifiy which files to skip. Defaults to [/javascripts\/vendor\/.\*.js\Z/, /_doc\/.*/]
    def call(release, options={})
      options = {
        :match => ["**/*.{css,js}"],
        :skip =>  [/javascripts\/vendor\/.*\.js\Z/, /_doc\/.*/],
        :delimiter => Regexp.escape("/* -------------------------------------------------------------------------------- */")
      }.update(options)
      
      compressor_options = {:line_break => 80}
      css_compressor = YUI::CssCompressor.new(compressor_options) 
      js_compressor = YUI::JavaScriptCompressor.new(compressor_options)
      
      # Add version numbers and minify the files
      release.get_files(options[:match], options[:skip]).each do |f|
        type = f[/\.(.+)$/,1]  
      
        data = File.read(f);
        File.open(f,"w") do |fh| 
          
          # Extract header and store for later use
          header = data[/\A(.+?)\n#{options[:delimiter]}\s*\n/m,1]
          minified = [header]
    
          # Actual minification
          release.log self,  "Minifying #{f}"
          case type
          when "css"
            minified << css_compressor.compress(data)
          when "js"
            minified << js_compressor.compress(data)
          end
    
          fh.write minified.join("\n")
        end
      end
      
    end
  end
end

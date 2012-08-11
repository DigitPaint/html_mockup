require 'tilt'
module HtmlMockup
  
  # Inject VERSION / DATE (i.e. in TOC)
  # r.inject({"VERSION" => release.version, "DATE" => release.date}, :into => %w{_doc/toc.html})
  
  # Inject CHANGELOG
  # r.inject({"CHANGELOG" => {:file => "", :filter => BlueCloth}}, :into => %w{_doc/changelog.html})  
  
  class Release::Injector
    
    # @example Simple variable injection (replaces [VARIABLE] into all .css files)
    #     {"[VARIABLE]" => "replacement"}, :into => %w{**/*.css}
    #
    # @example Regex variable injection (replaces all matches into test.js files)
    #     {/\/\*\s*\[BANNER\]\s*\*\// => "replacement"}, :into => %w{javacripts/test.js}    
    #
    # @example Simple variable injection with filtering (replaces [VARIABLE] with :content run through the markdown processor into all .html files)
    #     {"[VARIABLE]" => {:content => "# header one", :processor => "md"}, :into => %w{**/*.html}
    #    
    # @example Full file injection (replaces all matches of [CHANGELOG] with the contents of "CHANGELOG.md" into _doc/changelog.html)
    #
    #     {"CHANGELOG" => {:file => "CHANGELOG.md"}}, :into => %w{_doc/changelog.html}
    #
    # @example Full file injection with filtering (replaces all matches of [CHANGELOG] with the contents of "CHANGELOG" which ran through Markdown compresser into _doc/changelog.html)
    #
    #     {"CHANGELOG" => {:file => "CHANGELOG", :processor => "md"}}, :into => %w{_doc/changelog.html}
    #
    # Processors are based on Tilt (https://github.com/rtomayko/tilt). 
    # Currently supported/tested processors are:
    #
    # * 'md' for Markdown (bluecloth)
    # 
    # @param [Hash] variables Variables to inject. See example for more info
    # @option options [Array] :into An array of file globs relative to the build_path
    def initialize(variables, options)      
      @variables = variables
      @into = options[:into]
    end
    
    def call(release)
      files = release.get_files(@into)
      
      files.each do |f|
        c = File.read(f)
        injected_vars = []
        @variables.each do |variable, injection|
          if c.gsub!(variable, get_content(injection, release))
            injected_vars << variable
          end
        end
        release.log(self, "Injected variables #{injected_vars.inspect} into #{f}") if injected_vars.size > 0
        File.open(f,"w") { |fh| fh.write c }
      end
      
    end
    
    def get_content(injection, release)
      case injection
      when String
        injection
      when Hash
        get_complex_injection(injection, release)
      else
        if injection.respond_to?(:to_s)
          injection.to_s
        else
          raise ArgumentError, "Woah, what's this? #{injection.inspect}"
        end
      end
    end
    
    def get_complex_injection(injection, release)
      
      if injection[:file]
        content = File.read(release.build_path + injection[:file])
      else
        content = injection[:content]
      end
      
      raise ArgumentError, "No :content or :file specified" if !content

      if injection[:processor]
        if tmpl = Tilt[injection[:processor]]
          (tmpl.new{ content }).render
        else
          raise ArgumentError, "Unknown processor #{injection[:processor]}"
        end
      else
        content
      end
      
    end
    
  end
end

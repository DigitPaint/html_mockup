require File.dirname(__FILE__) + "/cli"

module HtmlMockup
  class Release
    
    attr_reader :config, :project
    
    attr_reader :finalizers, :injections, :stack, :cleanups
    
    class << self
    
      def default_stack
        []
      end    
    
      def default_finalizers
        [[self.get_callable(:dir, HtmlMockup::Release::Finalizers), {}]]
      end
            
      # Makes callable into a object that responds to call. 
      #
      # @param [#call, Symbol, Class] callable If callable already responds to #call will just return callable, a Symbol will be searched for in the scope parameter, a class will be instantiated (and checked if it will respond to #call)
      # @param [Module] scope The scope in which to search callable in if it's a Symbol
      def get_callable(callable, scope)
        return callable if callable.respond_to?(:call)
      
        if callable.kind_of?(Symbol)
          callable = camel_case(callable.to_s).to_sym
          if scope.constants.include?(callable)
            c = scope.const_get(callable)
            callable = c if c.is_a?(Class)
          end
        end
      
        if callable.kind_of?(Class)
          callable = callable.new
        end
      
        if callable.respond_to?(:call)
          callable
        else
          raise ArgumentError, "Could not resolve #{callable.inspect}. Callable must be an object that responds to #call or a symbol that resolve to such an object or a class with a #call instance method."
        end
      
      end
    
      # Nothing genius adjusted from:
      # http://stackoverflow.com/questions/9524457/converting-string-from-snake-case-to-camel-case-in-ruby
      def camel_case(string)
        return string if string !~ /_/ && string =~ /[A-Z]+.*/
        string.split('_').map{|e| e.capitalize}.join
      end
      
    end
    
    # @option config [Symbol] :scm The SCM to use (default = :git)
    # @option config [String, Pathname] :target_path The path/directory to put the release into
    # @option config [String, Pathname]:build_path Temporary path used to build the release
    # @option config [Boolean] :cleanup_build Wether or not to remove the build_path after we're done (default = true)
    def initialize(project, config = {})
      defaults = {
        :scm => :git,
        :source_path  => Pathname.new(Dir.pwd) + "html",
        :target_path => Pathname.new(Dir.pwd) + "releases",
        :build_path => Pathname.new(Dir.pwd) + "build",
        :cleanup_build => true
      }
      
      @config = {}.update(defaults).update(config)
      @project = project
      @stack = []
      @finalizers = []
    end
    
    # Accessor for target_path
    # The target_path is the path where the finalizers will put the release
    #
    # @return Pathname the target_path
    def target_path
      Pathname.new(self.config[:target_path])
    end
    
    # Accessor for build_path
    # The build_path is a temporary directory where the release will be built
    #
    # @return Pathname the build_path    
    def build_path
      Pathname.new(self.config[:build_path])      
    end
    
    # Accessor for source_path
    # The source path is the root of the mockup
    #
    # @return Pathanem the source_path
    def source_path
      Pathname.new(self.config[:source_path])
    end
    
    # Get the current SCM object
    def scm(force = false)
      return @_scm if @_scm && !force
      
      case self.config[:scm]
      when :git
        @_scm = Release::Scm::Git.new(:path => self.source_path)
      else
        raise "Unknown SCM #{options[:scm].inspect}"
      end
    end
    
    # Inject variables into files with an optional filter
    # 
    # @examples
    #   release.inject({"VERSION" => release.version, "DATE" => release.date}, :into => %w{_doc/toc.html})
    #   release.inject({"CHANGELOG" => {:file => "", :filter => BlueCloth}}, :into => %w{_doc/changelog.html})  
    def inject(variables, options)
      @stack << Injector.new(variables, options)
    end
    
    # Use a certain pre-processor
    #
    # @examples
    #   release.use :sprockets, sprockets_config
    def use(processor, options = {})
      @stack << [self.class.get_callable(processor, HtmlMockup::Release::Processors), options]
    end
    
    # Write out the whole release into a directory, zip file or anything you can imagine
    # #finalize can be called multiple times, it just will run all of them. 
    #
    # The default finalizer is :dir
    #
    # @param [Symbol, Proc] Finalizer to use
    #
    # @examples
    #   release.finalize :zip
    def finalize(finalizer, options = {})
      @finalizers << [self.class.get_callable(finalizer, HtmlMockup::Release::Finalizers), options]
    end
    
    # Files to clean up in the build directory just before finalization happens
    #
    # @param [String] Pattern to glob within build directory
    #
    # @examples
    #   release.cleanup "**/.DS_Store"
    def cleanup(pattern)
      @stack << Cleaner.new(pattern)
    end
    
    # Generates a banner if a block is given, or returns the currently set banner.
    # It automatically takes care of adding comment marks around the banner.
    #
    # The default banner looks like this:
    #
    # =======================
    # = Version : v1.0.0    =
    # = Date : 2012-06-20   =
    # =======================
    #
    #
    # @option options [:css,:js,:html,false] :comment Wether or not to comment the output and in what style. (default=js)
    def banner(options = {}, &block)
      options = {
        :comment => :js
      }.update(options)
      
      if block_given?
        @_banner = yield.to_s
      elsif !@_banner
        banner = []
        banner << "Version : #{self.scm.version}"
        banner << "Date  : #{self.scm.date.strftime("%Y-%m-%d")}"

        size = banner.inject(0){|mem,b| b.size > mem ? b.size : mem }
        banner.map!{|b| "= #{b.ljust(size)} =" }
        div = "=" * banner.first.size
        banner.unshift(div)
        banner << div
        @_banner = banner.join("\n")
      end
      
      if options[:comment]
        self.comment(@_banner, :style => options[:comment])
      else
        @_banner
      end
    end
    
    # Extract the mockup, this will happen anyway, and will always happen first
    # This method gives you a way to pass options to the extractor.
    #
    # @param Hash options Options hash passed to extractor
    #
    # @see  HtmlMockup::Extractor for more information
    # 
    # @deprecated Don't use the extractor anymore, use release.use(:mockup, options) processor
    def extract(options = {})
      self.warn(self, "Don't use the extractor anymore, use release.use(:mockup, options) and release.use(:url_relativizer, options) processors")
      @extractor_options = options
    end
    
    # Actually perform the release
    def run!
      # Validate paths
      validate_paths!
      
      # Extract mockup
      copy_source_path_to_build_path!
      
      validate_stack!
      
      # Run stack
      run_stack!
      
      # Run finalizers
      run_finalizers!
      
      # Cleanup
      cleanup! if self.config[:cleanup_build]
      
    end    
    
    # Write out a log message
    def log(part, msg, verbose = false, &block)
      if !verbose || verbose && self.project.options[:verbose]
        self.project.shell.say "\033[37m#{part.class.to_s}\033[0m" + " : " + msg.to_s, nil, true
      end
      if block_given?
        begin
          self.project.shell.padding = self.project.shell.padding + 1
          yield
        ensure
          self.project.shell.padding = self.project.shell.padding - 1
        end
      end
    end
    
    def debug(part, msg, &block)
      self.log(part, msg, true, &block)
    end
    
    # Write out a warning message
    def warn(part, msg)
      self.project.shell.say "\033[37m#{part.class.to_s}\033[0m" + " : " + "\033[31m#{msg.to_s}\033[0m", nil, true
    end
    
    
    # @param [Array] globs an array of file path globs that will be globbed against the build_path
    # @param [Array] excludes an array of regexps that will be excluded from the result
    def get_files(globs, excludes = [])
      files = globs.map{|g| Dir.glob(self.build_path + g) }.flatten
      if excludes.any?
        files.reject{|c| excludes.detect{|e| e.match(c) } }
      else
        files
      end
    end
    
    protected
    
    # ==============
    # = The runway =
    # ==============
    
    # Checks if build path exists (and cleans it up)
    # Checks if target path exists (if not, creates it)
    def validate_paths!
      if self.build_path.exist?
        log self, "Cleaning up previous build \"#{self.build_path}\""
        rm_rf(self.build_path)
      end
        
      if !self.target_path.exist?
        log self, "Creating target path \"#{self.target_path}\""
        mkdir self.target_path
      end
    end
    
    # Checks if deprecated extractor options have been set
    # Checks if the mockup will be runned
    def validate_stack!
      
      mockup_options = {}
      relativizer_options = {}
      run_relativizer = true
      if @extractor_options
        mockup_options = {:env => @extractor_options[:env]}
        relativizer_options = {:url_attributes => @extractor_options[:url_attributes]}
        run_relativizer = @extractor_options[:url_relativize]
      end
      
      unless @stack.find{|(processor, options)| processor === HtmlMockup::Release::Processors::Mockup }
        @stack.unshift([HtmlMockup::Release::Processors::UrlRelativizer.new, relativizer_options])        
        @stack.unshift([HtmlMockup::Release::Processors::Mockup.new, mockup_options])
      end
    end
    
    def copy_source_path_to_build_path!
      mkdir(self.build_path)
      cp_r(self.source_path.children, self.build_path)
    end
    
    def run_stack!
      @stack = self.class.default_stack.dup if @stack.empty?
      
      # call all objects in @stack
      @stack.each do |task|
        if (task.kind_of?(Array))
          task[0].call(self, task[1])
        else
          task.call(self)
        end
      end
    end

    def run_finalizers!
      @finalizers = self.class.default_finalizers.dup if @finalizers.empty?
      
      # call all objects in @finalizes
      @finalizers.each do |finalizer|
        finalizer[0].call(self, finalizer[1])
      end

    end
    
    def cleanup!
      log(self, "Cleaning up build path #{self.build_path}")
      rm_rf(self.build_path)
    end
    
    # @param [String] string The string to comment
    #
    # @option options [:html, :css, :js] :style The comment style to use (default=:js, which is the same as :css)
    # @option options [Boolean] :per_line Comment per line or make one block? (default=true)
    def comment(string, options = {})
      options = {
        :style => :css,
        :per_line => true
      }.update(options)
      
      commenters = {
        :html => Proc.new{|s| "<!-- #{s} -->" },
        :css => Proc.new{|s| "/* #{s} */" },
        :js => Proc.new{|s| "/* #{s} */" }                
      }
      
      commenter = commenters[options[:style]] || commenters[:js]
      
      if options[:per_line]
        string = string.split(/\r?\n/)
        string.map{|s| commenter.call(s) }.join("\n")
      else
        commenter.call(s)
      end
    end
  end
end

require File.dirname(__FILE__) + "/extractor"
require File.dirname(__FILE__) + "/release/scm"
require File.dirname(__FILE__) + "/release/injector"
require File.dirname(__FILE__) + "/release/cleaner"
require File.dirname(__FILE__) + "/release/finalizers"
require File.dirname(__FILE__) + "/release/processors"
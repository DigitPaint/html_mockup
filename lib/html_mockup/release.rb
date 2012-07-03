require File.dirname(__FILE__) + "/cli"

module HtmlMockup
  class Release
    
    attr_reader :config
    
    attr_reader :finalizers, :injections, :stack
    
    def self.default_stack
      []
    end    
    
    def self.default_finalizers
      [[:dir, {}]]
    end
            
    # @option config [Symbol] :scm The SCM to use (default = :git)
    # @option config [String, Pathname] :target_path The path/directory to put the release into
    # @option config [String, Pathname]:build_path Temporary path used to build the release
    # @option config [Boolean] :cleanup_build Wether or not to remove the build_path after we're done (default = true)
    def initialize(config = {})
      defaults = {
        :scm => :git,
        :source_path  => Pathname.new(Dir.pwd) + "html",
        :target_path => Pathname.new(Dir.pwd) + "releases",
        :build_path => Pathname.new(Dir.pwd) + "build",
        :cleanup_build => true
      }
      
      @config = {}.update(defaults).update(config)
      
      @finalizers = []
      @injections = []
      @stack = []
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
    def inject(injection)
      @injections << injection
    end
    
    # Use a certain pre-processor
    #
    # @examples
    #   release.use :sprockets, sprockets_config
    def use(processor, options = {})
      @stack << [processor, options]
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
      @finalizers << [finalizer, options]
    end
    
    # Generates a banner if a block is given, or returns the currently set banner.
    # It automatically takes care of adding comment marks around the banner.
    #
    # The default banner looks like this:
    #
    # =======================
    # = Version : v1.0.0    =
    # =  Date : 2012-06-20  =
    # =======================
    #
    def banner(&block)
      if block_given?
        @_banner = yield.to_s
        @_banner = @_banner.split("\r?\n").map{|b| "/* #{b} */"}.join("\n")
      elsif !@_banner
        banner = []
        banner << "Version : #{self.scm.version}"
        banner << "Date  : #{self.scm.date.strftime("%Y-%m-%d")}"

        size = banner.inject(0){|mem,b| b.size > mem ? b.size : mem }
        banner.map!{|b| "= #{b.ljust(size)} =" }
        div = "=" * banner.first.size
        banner.unshift(div)
        banner << div
        @_banner = banner.join("\n").map{|b| "/* #{b} */"}.join("\n")      
      else
        @_banner
      end
    end
    
    # Actually perform the release
    def release!
      # Validate paths
      validate_paths!
      
      # Extract valid mockup
      cli = HtmlMockup::Cli.new
      cli.invoke(:extract, [self.source_path, self.build_path])
      
      # Run stack
      run_stack!
      
      # Inject banners
      inject_banners!
      
      # Run injections
      run_injections!
      
      # Run finalizers
      run_finalizers!
      
      # Cleanup
      cleanup! if self.config[:cleanup_build]
      
    end    
    
    def log(part, msg)
      puts part.to_s + " : " + msg.to_s
    end
    
    protected
    
    # ==============
    # = The runway =
    # ==============
    
    def validate_paths!
      # Make sure the build_path is empty
      
      # Make sure the target_path exists
    end
    
    def run_stack!
      @stack = self.class.default_stack.dup if @stack.empty?
      @stack.each do |processor, options|
        get_callable(processor, HtmlMockup::Release::Processors).call(self, options)
      end
    end
    
    def inject_banners!
    end
    
    def run_injections!
      @injections.each do |injection|
        Injector.new(injection).call
      end
    end
    
    def run_finalizers!
      @finalizers = self.class.default_finalizers.dup if @finalizers.empty?
      @finalizers.each do |finalizer, options|
        get_callable(finalizer, HtmlMockup::Release::Finalizers).call(self, options)
      end
    end
    
    def cleanup!
    end
    
    # Makes callable into a object that responds to call. 
    #
    # @param [#call, Symbol, Class] callable If callable already responds to #call will just return callable, a Symbol will be searched for in the scope parameter, a class will be instantiated (and checked if it will respond to #call)
    # @param [Module] scope The scope in which to search callable in if it's a Symbol
    def get_callable(callable, scope)
      return callable if callable.respond_to?(:call)
      
      if callable.kind_of?(Symbol)
        # TODO camelcase callable
        callable = callable.to_s.capitalize.to_sym
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
        raise ArgumentError, "Callable must be an object that responds to #call or a symbol that resolve to such an object or a class with a #call instance method."
      end
      
    end
    
  end
end

require File.dirname(__FILE__) + "/release/scm"
require File.dirname(__FILE__) + "/release/finalizers"
require File.dirname(__FILE__) + "/release/processors"
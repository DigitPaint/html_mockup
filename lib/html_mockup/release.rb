module HtmlMockup
  class Release
    
    attr_reader :config
        
    # @option config [Symbol] :scm The SCM to use (default = :git)
    # @option config [String, Pathname] :target_path The path/directory to put the release into
    # @option config [String, Pathname]:build_path Temporary path used to build the release
    # @option config [Boolean] :cleanup_build Wether or not to remove the build_path after we're done (default = true)
    def initialize(config = {})
      defaults = {
        :scm => :git,
        :target_path => Pathname.new(Dir.pwd) + "releases",
        :build_path => Pathname.new(Dir.pwd) + "build",
        :cleanup_build => true
      }
      
      @config = {}.update(defaults).update(config)
    end
    
    # Accessor for target_path
    # @return Pathname the target_path
    def target_path
      Pathname.new(self.config[:target_path])
    end
    
    # Accessor for build_path
    # @return Pathname the build_path    
    def build_path
      Pathname.new(self.config[:build_path])      
    end
    
    # Get the current SCM object
    def scm(force = false)
      return @_scm if @_scm && !force
      
      case options[:scm]
      when :git
        @_scm = Release::Scm::Git.new(self.config)
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
    end
    
    # Use a certain pre-processor
    #
    # @examples
    #   release.use :sprockets, sprockets_config
    def use(processor, options = {})
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
    def finalize(finalizer)
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
    end    
    
  end
end
require File.dirname(__FILE__) + "/release/scm"
require 'pathname'

module HtmlMockup::Release::Scm
  class Git < Base
    
    # @option config [String] :ref Ref to use for current tag
    # @option config [String, Pathname] :path Path to working dir
    def initialize(config={})
      super(config)
      @config[:ref] ||= "HEAD"
    end
        
    # Version is either:
    # - the tagged version number (first "v" will be stripped) or
    # - the return value of "git describe --tags HEAD"
    # - the short SHA1 if there hasn't been a previous tag
    def version
      get_scm_data if @_version.nil?
      @_version
    end
    
    # Date will be Time.now if it can't be determined from GIT repository
    def date
      get_scm_data if @_date.nil?
      @_date
    end
  
    def previous
      self.class.new(@config.dup.update(:ref => get_previous_tag_name))
    end
    
    protected
    
    def get_previous_tag_name
      # Get list of SHA1 that have a ref
      begin
        sha1s = `git --git-dir=#{git_dir} log --pretty='%H' --simplify-by-decoration`.split("\n")
        tags = []
        while tags.size < 2 && sha1s.any?
          sha1 = sha1s.shift
          tag = `git --git-dir=#{git_dir} describe --tags --exact-match #{sha1} 2>/dev/null`.strip
          tags << tag if !tag.empty?
        end
        tags.last
      rescue
        raise "Could not get previous tag"
      end      
    end
    
    def git_dir
      @git_dir ||= find_git_dir(@config[:path])
    end

    # Some hackery to determine if we're on a tagged version or not
    def get_scm_data(ref = @config[:ref])
      @_version = ""
      @_date = Time.now
      begin
        if File.exist?(git_dir)
          @_version = `git --git-dir=#{git_dir} describe --tags #{ref} 2>&1`
          
          if $?.to_i > 0
            # HEAD is not a tagged verison, get the short SHA1 instead            
            @_version = `git --git-dir=#{git_dir} show #{ref} --format=format:"%h" --quiet 2>&1` 
          else
            # HEAD is a tagged version, if version is prefixed with "v" it will be stripped off
            @_version.gsub!(/^v/,"")
          end
          @_version.strip!
    
          # Get the date in epoch time
          date = `git --git-dir=#{git_dir} show #{ref} --format=format:"%ct" --quiet 2>&1`
          if date =~ /\d+/
            @_date = Time.at(date.to_i)
          else
            @_date = Time.now
          end
    
        end
      rescue RuntimeError => e
      end

    end
    
    # Find the git dir
    def find_git_dir(path)
      path = Pathname.new(path).realpath
      while path.parent != path && !(path + ".git").directory?
        path = path.parent
      end
      
      path = path + ".git"
      
      raise "Could not find suitable .git dir in #{path}" if !path.directory?

      path
    end
    
  end
end


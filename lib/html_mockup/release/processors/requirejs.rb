require 'fileutils'
module HtmlMockup::Release::Processors
  class Requirejs < Base
    
    def initialize(options = {})
      @options = {
        :build_files => {"javascripts/site.build.js" => "javascripts"},
        :rjs => "r.js",
        :node => "node"
      }.update(options)
    end
    

    # @option options [Hash] :build_files An a hash of files to build (as key) and the target directory in the release to put it as value, each one will be built in a separate directory. (default is {"javascripts/site.build.js" => "javascripts"})
    # @option options [String] :node The system path for node (defaults to "node" in path)
    # @option options [String] :rjs The system path to the requirejs optimizer (r.js) (defaults to "../vendor/requirejs/r.js" (relative to source_path))
    def call(release, options={})
      @options.update(options)
      
      begin
        `#{@options[:node]} -v`
      rescue Errno::ENOENT
        raise RuntimeError, "Could not find node in #{@options[:node].inspect}"
      end
      
      rjs_command = rjs_check()
      
      @options[:build_files].each do |build_file, target|
        build_file = release.build_path + build_file
        target = release.build_path + target
        release.log(self, "Optimizing #{build_file}")
                
        # Hack to create tempfile in build
        t = Tempfile.new("requirejs", release.build_path)
        tmp_build_dir = t.path
        t.close
        t.unlink
      
        # Run r.js optimizer
        output = `#{rjs_command} -o #{build_file} dir=#{tmp_build_dir}`
        
        # Check if r.js succeeded
        unless $?.success?
          raise RuntimeError, "Asset compilation with node failed.\nr.js output:\n #{output}"
        end
        
        if File.exist?(target)
          release.log(self, "Removing target #{target}")
          FileUtils.rm_rf(target)
        end        
        
        # Move the tmp_build_dir to target
        FileUtils.mv(tmp_build_dir, target)
      end
    end
    
    
    # Incase both a file and bin version are availble file version is taken
    #
    # @return rjs_command to invoke r.js optimizer with

    def rjs_check(path = @options[:rjs])
      rjs_command = rjs_file(path) || rjs_bin(path)
      if !(rjs_command)
        raise RuntimeError, "Could not find r.js optimizer in #{path.inspect} - try updating this by npm install -g requirejs"
      end
      rjs_command
    end
    
    protected

    # Checks if the param is the r.js lib from file system
    # 
    # @param [String] Path r.js lib may be kept to be invoked with node
    # @return [String] the cli invokement string
    def rjs_file(path)
      if File.exist?(path)
        "#{@options[:node]} #{path}"
      else
        false
      end
    end
    
    # Checks if r.js is installed as bin
    #
    # @param [String] Path to r.js bin
    # @return [String] the cli invokement string
    def rjs_bin(path)
      begin
        `#{path} -v`
      rescue Errno::ENOENT
        false
      else
        "#{path}"
      end
    end
    
  end
end

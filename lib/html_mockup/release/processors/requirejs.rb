require 'fileutils'
module HtmlMockup::Release::Processors
  class Requirejs < Base

    # @option options [Hash] :build_files An a hash of files to build (as key) and the target directory in the release to put it as value, each one will be built in a separate directory. (default is {"javascripts/site.build.js" => "javascripts"})
    # @option options [String] :node The system path for node (defaults to "node" in path)
    # @option options [String] :rjs The system path to the requirejs optimizer (r.js) (defaults to "../vendor/requirejs/r.js" (relative to source_path))
    def call(release, options={})
      options = {
        :build_files => {"javascripts/site.build.js" => "javascripts"},
        :rjs => "r.js",
        :node => "node"
      }.update(options)
      
      begin
        `#{options[:node]} -v`
      rescue Errno::ENOENT
        raise RuntimeError, "Could not find node in #{node.inspect}"
      end

      begin
        `#{options[:rjs]} -v`
      rescue Errno::ENOENT
        raise RuntimeError, "Could not find r.js optimizer in #{rjs.inspect} - try updating this by npm install -g requirejs"
      end
      
      options[:build_files].each do |build_file, target|
        build_file = release.build_path + build_file
        target = release.build_path + target
        release.log(self, "Optimizing #{build_file}")
                
        # Hack to create tempfile in build
        t = Tempfile.new("requirejs", release.build_path)
        tmp_build_dir = t.path
        t.close
        t.unlink
      
        # Run r.js optimizer
        output = `#{options[:rjs]} -o #{build_file} dir=#{tmp_build_dir}`
        
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
  end
end

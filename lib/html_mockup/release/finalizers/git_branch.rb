# Finalizes the release into a specific branch of a repository and pushes it
#
class GitBranch < HtmlMockup::Release::Finalizers::Base
 
  # @param Hash options The options
  #
  # @option options String :remote The remote repository (default is the origin of the current repository)
  # @option options String :branch The remote branch (default is "gh-pages")
  # @option options Boolean :cleanup Cleanup temp dir afterwards (default is true)  
  # @option options Boolean :push Push to remote (default is true)    
  def initialize(options={})
    @options = {
      :remote => nil,
      :branch => "gh-pages",
      :cleanup => true,
      :push => true
    }
  end
  
  
  def call(release, options = {})
    options = @options.dup.update(options)  
    git_dir = find_git_dir(release.project.path)
    
    # 0. Get remote
    unless remote = (options[:remote] || `git --git-dir=#{git_dir} config --get remote.origin.url`).strip
      raise "No remote found for origin"
    end
    
    e_remote = Shellwords.escape(remote)
    e_branch = Shellwords.escape(options[:branch])

    tmp_dir = Pathname.new(Dir.mktmpdir)
    clone_dir = tmp_dir + "clone"
    
    # Check if remote already has branch
    if `git ls-remote --heads #{e_remote} refs/heads/#{e_branch}` == ""
      release.log(self, "Creating empty branch")
      # Branch does not exist yet
      FileUtils.mkdir(clone_dir)
      Dir.chdir(clone_dir) do
        `git init`
        `git remote add origin #{e_remote}`
        `git checkout -b #{e_branch}`
      end
    else
      release.log(self, "Cloning existing repo")
      # 1. Clone into different directory      
      `git clone #{e_remote} --branch #{e_branch} --single-branch #{clone_dir}`
    end
    
    release.log(self, "Working git magic in #{clone_dir}")
    Dir.chdir(clone_dir) do
      # 3. Copy changes
      FileUtils.rm_rf("*")
      FileUtils.cp_r release.build_path.to_s + "/.", clone_dir.to_s
      
      # 4. Add all files
      `git add .`
    
      # 5. Commit
      `git commit -a -m "Release #{release.scm.version}"`

      # 6. Git push
      if options[:push]
        `git push origin #{e_branch}`
      end
    end
    
    if options[:cleanup]
      FileUtils.rm_rf(tmp_dir)
    end
    
  end
  
  protected
  
  # Find the git dir
  # TODO this is just a copy from release/scm/git.rb 
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
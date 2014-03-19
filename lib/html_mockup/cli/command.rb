module HtmlMockup

  class Cli::Command < Thor::Group

    class_option :path, 
      :desc => "Path to generate the new generator",
      :type => :string, 
      :required => false, 
      :default => "."

    class_option :verbose,
      :desc =>  "Set's verbose output",
      :aliases => ["-v"],
      :default => false,
      :type => :boolean


    class_option :html_path,
      :desc => 'The document root, defaults to "[directory]/html"',
      :type => :string


    class_option :partial_path,
      :desc => 'Defaults to [directory]/partials',
      :type => :string


    # TODO: handle options
    def initialize_project
      if((Pathname.new(options[:path]) + "../partials").exist?)
        puts "[ERROR]: Don't use the \"html\" path, use the project base path instead"
        exit(1)
      end
      
      @project = Project.new(options[:path], {:shell => self.shell}.update(options))
    end

    protected

    def project_banner(project)
      puts "  Html: \"#{project.html_path}\""
      puts "  Partials: \"#{project.partial_path}\""
    end
  end

end
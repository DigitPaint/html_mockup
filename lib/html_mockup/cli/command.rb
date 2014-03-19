module HtmlMockup

  class Cli::Command < Thor::Group

    class_option :verbose,
      :desc =>  "Set's verbose output",
      :aliases => ["-v"],
      :default => false,
      :type => :boolean

    def initialize_project
      @project = Cli::Base.project
    end

    protected

    def project_banner(project)
      puts "  Html: \"#{project.html_path}\""
      puts "  Partials: \"#{project.partial_path}\""
    end
  end

end
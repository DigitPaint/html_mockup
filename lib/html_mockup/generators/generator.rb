class HtmlMockup::Generators::GeneratorGenerator < HtmlMockup::Generators::Base
  
  include Thor::Actions
  
  desc "Create your own generator for html_mockup"
  argument :name, :type => :string, :required => true, :desc => "Name of the new generator"
  argument :path, :type => :string, :required => true, :desc => "Path to generate the new generator"
  # class_option :template, :type => :string, :aliases => ["-t"], :desc => "Template to use, can be a path or a git repository remote, uses built in minimal as default"
  
  def self.source_root
    File.dirname(__FILE__)
  end

  def create_lib_file
    destination = "#{path}/#{name}_generator.rb"
    template('templates/generator.tt', destination)
    say "Add `require #{destination}` to your mockup file and run mockup generate #{name}."
  end

  
end

HtmlMockup::Generators::Base.register HtmlMockup::Generators::GeneratorGenerator
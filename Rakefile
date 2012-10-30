
task :default => [:jewelerer]

task :test do
  ruby "test/unit/processors/RequireJSTests.rb"
end

task :jewelerer do

  begin
    require 'jeweler'
    Jeweler::Tasks.new do |gemspec|
      gemspec.name = "html_mockup"
      gemspec.email = "flurin@digitpaint.nl"
      gemspec.homepage = "http://github.com/flurin/html_mockup"
      gemspec.summary = "HTML Mockup is a set of tools to create self-containing HTML mockups."    
      gemspec.authors = ["Flurin Egger"]

      gemspec.files = FileList['lib/**/*.rb'] + FileList['bin/*'] + FileList['examples/**/*']
      gemspec.test_files = []
      gemspec.has_rdoc = false

      gemspec.add_dependency('thor', '~> 0.16.0')
      gemspec.add_dependency('rack', '>= 1.0.0')
    end
  rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
  end

end
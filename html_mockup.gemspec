# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{html_mockup}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Flurin Egger"]
  s.date = %q{2009-04-14}
  s.default_executable = %q{mockup}
  s.email = %q{f.p.egger@gmail.com}
  s.executables = ["mockup"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "bin/mockup",
    "examples/html/green.gif",
    "examples/html/index.html",
    "examples/partials/test.part.rhtml",
    "examples/script/server",
    "lib/html_mockup/cli.rb",
    "lib/html_mockup/rack/html_mockup.rb",
    "lib/html_mockup/rack/html_validator.rb",
    "lib/html_mockup/template.rb",
    "lib/html_mockup/w3c_validator.rb"
  ]
  s.homepage = %q{http://github.com/flurin/html_mockup}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{HTML Mockup is a set of tools to create self-containing HTML mockups.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0.9.9"])
      s.add_runtime_dependency(%q<rack>, [">= 0.3.0"])
    else
      s.add_dependency(%q<thor>, [">= 0.9.9"])
      s.add_dependency(%q<rack>, [">= 0.3.0"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0.9.9"])
    s.add_dependency(%q<rack>, [">= 0.3.0"])
  end
end

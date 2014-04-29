# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "roger"
  s.version = "0.0.1"
  
  s.authors = ["Flurin Egger", "Edwin van der Graaf", "Joran Kapteijns"]
  s.email = ["info@digitpaint.nl", "flurin@digitpaint.nl"]  
  s.homepage = "http://github.com/digitpaint/html_mockup"
  s.summary = "Roger is a set of tools to create self-containing HTML mockups."
  s.licenses = ["MIT"]

  s.date = Time.now.strftime("%Y-%m-%d")
  
  s.files = []
  s.test_files = []
  s.executables   = []
  s.require_paths = ["lib"]  
  
  s.extra_rdoc_files = [
    "README.md"
  ]
  
  s.rdoc_options = ["--charset=UTF-8"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.add_dependency("html_mockup", ["~> 0.8.4"])
end

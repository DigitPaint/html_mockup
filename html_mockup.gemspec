# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "html_mockup"
  s.version = "0.7.3"
  
  s.authors = ["Flurin Egger", "Edwin van der Graaf"]
  s.email = ["info@digitpaint.nl", "flurin@digitpaint.nl"]  
  s.homepage = "http://github.com/digitpaint/html_mockup"
  s.summary = "HTML Mockup is a set of tools to create self-containing HTML mockups."
  s.licenses = ["MIT"]

  s.date = Time.now.strftime("%Y-%m-%d")
  
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]  
  
  s.extra_rdoc_files = [
    "README.rdoc"
  ]  
  
  s.rdoc_options = ["--charset=UTF-8"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.add_dependency("thor", ["~> 0.16.0"])
  s.add_dependency("rack", [">= 1.0.0"])
  s.add_dependency("tilt", [">= 0"])
  s.add_dependency("hpricot", [">= 0.6.4"])  
end

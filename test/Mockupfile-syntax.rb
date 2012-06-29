# Example idea for a Mockupfile, a lot of this has to have a sensible default.

Sass::Plugin.options[:style] = :expanded
Sass::Plugin.options[:template_location] = "./html/stylesheets"
Sass::Plugin.options[:css_location] = "./html/stylesheets"

config = {}
sass_config = {}
sprockets_config = {}

config[:root_path] = Pathname.new(File.dirname(__FILE__)) + "../html"
config[:partial_path] = (config[:root_path] + "../partials/").realpath
# config[:port] = 9000 # Should not really have to be configured
config[:stylesheet_path] = "./html/stylesheets"

mockup.serve(config) do |server|
  server.use :sass, sass_config
  server.use :sprockets, sprockets_config
end

mockup.release(config) do |release|
  release.target_path # The target path where releases are put
  release.build_path # The path where the release gets built
  release.release_path # The actual path where the release wil be put if done (can be a zip file too)
  
  # Extract mockup
  
  # Get git version
  release.scm.previous # Get the previous version SCM op (looks for tags)
  
  release.scm.version # Get the git version
  release.scm.date # Get the git date
  release.scm.sha1 # SHA1 commit
  
  # release.scm.tag! # is this possible?
  
  # Create banner (has a default)
  release.banner do
    "bla bla bla"
  end
  
  # Sassify CSS
  release.use :sass, sass_config
  
  # Sprocketize JS
  release.use :sprockets, sprockets_config
  
  # Minify & add banners
  release.use :yuicompressor, {}
  
  # Inject VERSION / DATE (i.e. in TOC)
  release.inject({"VERSION" => release.version, "DATE" => release.date}, :into => %w{_doc/toc.html})
  
  # Inject CHANGELOG
  release.inject({"CHANGELOG" => {:file => "", :filter => BlueCloth}}, :into => %w{_doc/changelog.html})  
  
  # Inject NOTES
  release.inject({"NOTES" => {:file => "", :filter => BlueCloth}}, :into => %w{_doc/notes.html})  
  
  
  # Move to release / zip
  release.finalize :zip
  release.finalize :dir
  release.finalize lambda{|build_path|  }
  
end
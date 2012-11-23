# Example idea for a Mockupfile, a lot of this has to have a sensible default.

Sass::Plugin.options[:style] = :expanded
Sass::Plugin.options[:template_location] = "./html/stylesheets"
Sass::Plugin.options[:css_location] = "./html/stylesheets"

# These are defaults, but can be set here
# mockup.project.html_path = mockup.project.path + "html"
# mockup.project.partial_path = mockup.project.path + "partials"

mockup.serve(config) do |server|
  server.use :sass
end

mockup.release(config) do |release|
  
  release.target_path # The target path where releases are put
  release.build_path # The path where the release gets built
  release.source_path # The source for this mockup
  
  # Extract mockup
  # Pass custom config to the extractor, this is optional
  # release.extract :url_attributes =>  %w{src href action data-main}
  
  # Get git version
  release.scm.previous # Get the previous version SCM op (looks for tags)
  release.scm.version # Get the git version
  release.scm.date # Get the git date
    
  # Create custom banner
  release.banner do
    "bla bla bla"
  end
  
  # The default banner looks like this:
  #
  # =======================
  # = Version : v1.0.0    =
  # = Date : 2012-06-20   =
  # =======================  
  
  # Sassify CSS (this are the defaults too), all options except form :match and :skip are passed to Sass.compile_file
  # release.use :sass, :match => ["stylesheets/**/*.scss"], :skip => [/_.*\.scss\Z/], :style => :expanded
  # The previous statement is the same as:
  release.use :sass
  
  # Run requirejs optimizer
  # release.use :requirejs, {
  #     :build_files => {"javascripts/site.build.js" => "javascripts"},
  #     :rjs => release.source_path + "../vendor/requirejs/r.js",
  #     :node => "node"
  #   }
  release.use :requirejs
    
  # Minify, will not minify anything above the :delimiter
  # release.use :yuicompressor, {
  #   :match => ["**/*.{css,js}"],
  #   :skip =>  [/javascripts\/vendor\/.*\.js\Z/, /_doc\/.*/],
  #   :delimiter => Regexp.escape("/* -------------------------------------------------------------------------------- */")
  # }
  # The previous statement is the same as:
  release.use :yuicompressor
  
  
  # Inject VERSION / DATE (i.e. in TOC)
  r.inject({"[VERSION]" => release.scm.version, "[DATE]" => release.scm.date.strftime("%Y-%m-%d")}, :into => %w{_doc/toc.html})
  
  # Inject Banners on everything matching the regexp in all .css files
  # The banner will be commented as CSS.
  release.inject({ /\/\*\s*\[BANNER\]\s*\*\// => r.banner(:comment => :css)}, :into => %w{**/*.css})
  
  # Inject CHANGELOG
  release.inject({"[CHANGELOG]" => {:file => "../CHANGELOG", :processor => 'md'}}, :into => %w{_doc/changelog.html})  
  
  # Inject NOTES
  release.inject({"[NOTES]" => {:file => "../NOTES.md", :processor => 'md'}}, :into => %w{_doc/notes.html})    
  
  # Cleanup on the build
  release.cleanup "**/.DS_Store"  
  
  # Finalize the release
  # This is the default finalizer so not required
  # release.finalize :dir
    
end
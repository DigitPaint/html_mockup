{<img src="https://badge.fury.io/rb/html_mockup.png" alt="Gem Version" />}[http://badge.fury.io/rb/html_mockup]

== HtmlMockup

HTML Mockup is a set of tools to create self-containing HTML mockups. HtmlMockup gives you the flexibility
of a templatinglanguage but at the same time keeps all HTML files viewable. HTML comments are 
used to  determine what partial (sub-template) to render.

HtmlMockup also provides tools for HTML validation. 

=== Requirements
HtmlMockup requires the following dependencies

* Ruby 1.8.x (or 1.9.x)
* Rubygems
* Thor (to use mockup binary)
* Rack > 1.0 (to use mockup serve) 

=== Usage

Just write regular HTML files and include comment's like this: 

  <!-- [START:partial_name] -->Text<!-- [STOP:partial_name] -->

The data between the tags will be replaced by the partial contents. Partials are searched in
"../partials" relative to the directory the script you run resides in. This can be overridden with
commandline parameters. Partials always must have a .part.r?html ending and are evaluated as ERB during
insertion.

=== Syntax for HTML files

==== Standard partials

  <!-- [START:partial_name] -->Text<!-- [STOP:partial_name] -->

==== Pass parameters to partials

You can pass in parameters to partials in the format of key=value&key2=value2 (it's just a regular CGI
query string and is parsed by CGI#parse). The partials wich are evaluated as ERB can access the variables
through standard instance methods. The example below would create the instance variable @key.

  <!-- [START:partial_name?key=value] -->Text<!-- [STOP:partial_name] -->

=== Partials in subdirectories

The partials path can have it's own directory structure. You can create tags with slashes in them
to access partials in subdirectories.


=== Mockup commandline

==== mockup serve [directory]

Serve can be used during development as a simple webserver (Puma, Mongrel, Thin, Webrick). It also supports on-the-fly HTML validation. 

The directory to serve must contain `[directory]/html` and `[directory]/partials` (unless you have specified `--partial_path` and `--html_path`)

Options:
--port:: The port the server should listen on. Defaults to 9000
--partial_path:: the path where the partial files can be found (*.part.html), defaults to directory `[directory]/partials`
--html_path:: the path where the html files can be found (*.html), defaults to directory `[directory]/html`
--validate:: Flag to set wether or not we should validate all html files (defaults to false)

==== mockup release [directory]

Makes a release of the current mockup project

==== mockup new [directory]

Generate creates a directory structure in directory for use with new HTML mockups.

==== mockup extract [source_path] [target_path]

Extract a fully relative html mockup into target_path. It will expand all absolute href's, src's and action's into relative links if they are absolute

Options:
--partial_path:: Defaults to [directory]/partials
--filter:: What files should be converted defaults to **/*.html

==== mockup validate [directory/file]

Validates all files within directory or just file with the W3C validator webservice. 

Options:
--show_valid:: Flag to print a line for each valid file too (defaults to false)
--filter:: What files should be validated, defaults to [^_]*.html

=== Copyright & license
Copyright (c) 2012 Flurin Egger, Edwin van der Graaf, DigitPaint, MIT Style License. (see MIT-LICENSE)

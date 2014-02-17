# Changelog

## Version EDGE
* Don't crash on non-existent partials/layouts path
* Add more logging in verbose mode when extracting mockup

## Version 0.8.0
* Set content type header in response when rendering templates
* Add option to prompt user before performing rsync finalizer (defaults to true)
* Fix zip finalizer to use options[:zip] in actuall executed command too
* Logger now outputs color and has support for warning messages
* Mockup templating is now fully handled with Tilt
* Mockup extraction and URL relativization etc. for release are now done in their respective processors (will be added automatically if you haven't added them yourself.) This gives a fine-grained control over the point in time when these processors are ran.
* Add a testproject to the repository
* Add support for layouts
* Add a `git_branch` finalizer that allows us to release to a branch on a repository (this makes it easy to release github pages)
* Allow requirejs processor to work wih single files as well
* Expose server options to mockup so you can configure a https server if you want
* Minor fixes

## Version 0.7.4
* Allow for underscores in .scss files when releasing

## Version 0.7.3
* Set a sensible `load_path` for sass in release mode (defaults to `build_path + "stylesheets"`)
* Also automatically require the rsync finalizers

## Version 0.7.2
* Add zip finalizers
* Instead of complaining about existing build path, just clean it up
* Instead of complaining about unexisting target path, just create it
* Automatically require all built-in procssors

## Version 0.7.1
* Pass target_file to the ERBTemplate to files with erb errors
* Fix env["MOCKUP_PROJECT"] setting in extractor

## Version 0.7.0
* Replace --quiet with -s in as it's no longer supported in newer GIT versions
* Add support for ENV passing to the partials
* Add support for single file processing and env passing in the extractor (release)
* Refactor path and url resolving
* Allow `.html` files to be processed by ERB (both in release and serve)
* Pass "MOCKUP_PROJECT" variable to env (both in release and serve)

## Version 0.6.5
* Allow disabling of URL relativizing in the extractor with `release.extract :url_relativize => false`
* Add missing Hpricot dependency to gem

## Version 0.6.4
* Add RsyncFinalizer to automatically upload your mockup

## Version 0.6.3
* Add license to gemspec
* Fix default_template in gem
* Add option to allow for resolving urls in custom attributes in the extractor (via `release.extract(options_hash)`)
* Add more unified interface to finalizers and processors
* Fix error if node can't be found in Processors::Requirejs

## Version 0.6.2
* Improved cleaner with more robust tests

## Version 0.6.1
* Correctly pass file and linenumber to Mockupfile evaluation
* Add the tilt gem as a requirement (needed for injectors in release)
* Make the cleaner also remove directories, also make it more safe (it will never delete stuff above the build_path)

## Version 0.6.0
* Pass command line options to underlying objets
* Update docs
* The different Processors, injections and cleanups are run in order as specified. Finalizers will always be run last in their own order.
* Replace CLI "generate" command with "new" subcommand and add support for remote git skeletons based on Thor templating.
* Add most simple mockup directory as default_template
* Requirejs processor updated so it will search for a global r.js command, a local npm r.js command and a vendored r.js command
* Minor fixes and changes
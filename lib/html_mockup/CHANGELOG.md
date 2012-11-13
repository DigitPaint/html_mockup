# Changelog

## Version 0.6.0
* Pass command line options to underlying objets
* Update docs
* The different Processors, injections and cleanups are run in order as specified. Finalizers will always be run last in their own order.
* Replace CLI "generate" command with "new" subcommand and add support for remote git skeletons based on Thor templating.
* Add most simple mockup directory as default_template
* Requirejs processor updated so it will search for a global r.js command, a local npm r.js command and a vendored r.js command
* Minor fixes and changes
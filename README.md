# HtmlMockup

[![Gem Version](https://badge.fury.io/rb/html_mockup.png)](http://badge.fury.io/rb/html_mockup)

## What is it?

HtmlMockup is your friendly front-end development toolbox! It helps you with these 4 things:

1. **Generate** : Set up your projects
1. **Serve** : Development server
1. **Test** : Test/lint your stuff
1. **Release** : Release your code

## Get started

We assume you have a working Ruby 1.9.x or higher running.

1. Install HtmlMockup

    ```shell
    gem install html_mockup
    ```

1. Create a new project

    ```shell
    mockup generate new PROJECT_DIR
    ```

    Replace `PROJECT_DIR` with your project name

1. Start the development server

    ```shell
    mockup serve
    ```

    Open your webbrowser and go to `http://localhost:9000/`

1. Release your project

    ```shell
    mockup release
    ```

## Where to go from here?

Read more documentation:

* [**Templating** Learn the power of HtmlMockup built in templating](doc/templating.md)
* [**CLI** Learn about the different `mockup` commands](doc/cli.md)
* [**Mockupfile** Learn how to configure and extend your Project](doc/mockupfile.md)

## Why?

When we started with HtmlMockup there was no Grunt/Gulp/whatever and with us being a Ruby shop we wrote HtmlMockup. Since it's beginning it has evolved into quite a powerful tool. 

Why would HtmlMockup be better than any other?
It's not it just does some things differently.

* Ruby
* Code over configuration
* Based on little modules, simple to extend
* Streams & files
* 4 easy commands separate concerns

## Contributors

[View contributors](https://github.com/digitpaint/html_mockup/graphs/contributors)

## License

(The MIT License)

Copyright (c) 2014 Digitpaint

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

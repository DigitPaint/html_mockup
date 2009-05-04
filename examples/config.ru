require 'pathname'

begin
  require File.dirname(__FILE__) + "/../vendor/html_mockup/lib/html_mockup/server"
rescue LoadError => e
  require 'rubygems'
  require 'html_mockup/server'
end

root_path = Pathname.new(File.dirname(__FILE__)) + "html"
partial_path = (root_path + "../partials/").realpath

mockup = HtmlMockup::Server.new(root_path,partial_path)

run mockup.application


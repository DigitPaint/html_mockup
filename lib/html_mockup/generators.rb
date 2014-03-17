require 'thor'
require 'thor/group'

module HtmlMockup
  module Generators

    class Generate < Thor
    end

    class Base < Thor::Group
      def self.register(sub)
        name = sub.to_s.sub(/Generator$/, "").sub(/^.*Generators::/,"").downcase
        usage = "#{name} #{sub.arguments.map{ |arg| arg.banner }.join(" ")}"
        long_desc =  sub.desc || "Run #{name} generator"
        
        Generate.register sub, name, usage, long_desc
        Generate.tasks[name].options = sub.class_options if sub.class_options
      end
    end

  end
end

# Default generators
require File.dirname(__FILE__) + "/generators/new"
require File.dirname(__FILE__) + "/generators/generator"
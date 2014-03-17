require 'thor'

module HtmlMockup
  module Generators

    class Generate < Thor
    end

    class Base < Thor::Group
      def self.inherited(sub)
	name = sub.to_s.sub(/Generator$/, "").sub(/^.*Generators::/,"").downcase
	Generate.register sub, name, name, "Run #{name}"
      end
    end

  end
end

# Default generators
require File.dirname(__FILE__) + "/generators/new"
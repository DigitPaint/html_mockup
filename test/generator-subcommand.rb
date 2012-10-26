#!/usr/bin/env ruby

# This testfile is just a small testcase on how
# to do something with nested generators. It's
# just some basics and needs to be explored further.

# What we need for/from a generator:
# - It needs to be registered in our Generators::Generate class
# - It needs to be automatically loaded from:
#    - The mockup: <root>/generators/<name>/<name>_generator.rb
#    - The gem
#    - Other gems which have been manually required (?)
# - It needs to have access to the current Mockup::Project instance
# - It needs to have the following file structure:
#    - <name>
#      - <name>_generator.rb
#      - ...support files...

require 'rubygems'
require 'thor'
require 'thor/group'


module Generators
  class Generate < Thor
  end

  class GeneratorBase < Thor::Group
    def self.inherited(sub)
      name = sub.to_s.sub(/Generator$/, "").sub(/^Generators::/,"").downcase
      Generate.register sub, name, name, "Run #{name}"
    end
  end

  class ThingGenerator < GeneratorBase
    def done
      puts "Yep, done the thing"
    end
  end

  class BlingGenerator < GeneratorBase
    def done
      puts "Here is some bling!"
    end
  end
end

module CLI
  class Base < Thor  
    register Generators::Generate, "generate", "generate [COMMAND]", "Run a generator"
  end
end

CLI::Base.start
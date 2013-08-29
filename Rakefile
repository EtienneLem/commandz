$:.unshift File.join(File.dirname(__FILE__), *%w[lib])
require 'tasks/task_helpers'

# Rubygems
require 'bundler'
Bundler::GemHelper.install_tasks

# Dependencies
require 'uglifier'
require 'commandz'
require 'sprockets'

# Tasks
desc 'Merge, compiles and minify CoffeeScript files'
task :compile do
  @environment = Sprockets::Environment.new
  @environment.append_path 'lib/assets/javascripts'
  @environment.js_compressor = Uglifier.new(mangle: true)

  compile('commandz.js')
end

desc 'run Jasmine specs'
task :spec do
  system('bundle exec jasmine-headless-webkit')
end

# Helpers
def compile(file)
  minjs = @environment[file].to_s
  out = "#{file.sub('.js', '.min.js')}"

  File.open(out, 'w') { |f| f.write(copyright + minjs + "\n") }
  success "Compiled #{out}"
end

def copyright
  @copyright ||= <<-EOS
/*
* CommandZ v#{CommandZ::VERSION}
* https://github.com/EtienneLem/commandz
*
* Copyright 2013, Etienne Lemay http://heliom.ca
* Released under the MIT license
*
* Date: #{Time.now}
*/
EOS
end

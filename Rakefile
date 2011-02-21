require 'bundler'
Bundler.setup

Bundler::GemHelper.install_tasks

require 'yard'
YARD::Rake::YardocTask.new

require 'rake/clean'
CLEAN.include 'coverage', 'doc', 'pkg'

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc "Testing library (with coverage)"
task :coverage do
  sh %{bundle exec rcov -Ilib test/*_test.rb}
end

desc "Creating documentation"
task :doc do
  PKG_SUMMARY      = 'Serialize an ActiveRecord::Base attribute via JSON'
  PKG_RDOC_OPTIONS = [ '--main', 'README', '--title', PKG_SUMMARY ]
  sh 'rdoc', *(PKG_RDOC_OPTIONS + Dir['lib/**/*.rb']  + [ 'README' ])
end

task :default => :test

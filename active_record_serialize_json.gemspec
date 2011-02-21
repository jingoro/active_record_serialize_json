# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_record/serialize_json/version"

Gem::Specification.new do |s|
  s.name        = 'active_record_serialize_json'
  s.version     = ActiveRecord::SerializeJSON::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Florian Frank"]
  s.email       = ["flori@ping.de"]
  s.homepage    = "https://github.com/flori/active_record_serialize_json"
  s.summary     = 'Serialize an ActiveRecord::Base attribute via JSON'
  s.description = s.summary + ' in Ruby on Rails'

  s.rubyforge_project = "active_record_serialize_json"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'json', '>= 1.4'
  s.add_dependency 'activerecord', '>= 2.3'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'yard'

end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mls"
  s.version     = '1.2.0'
  s.authors     = ["Jon Bracy", "James R. Bracy"]
  s.email       = ["jon@42floors.com", "james@42floors.com"]
  s.homepage    = "http://mls.42floors.com"
  s.summary     = %q{42Floors MLS Client}
  s.description = %q{Ruby library for integrating with the 42Floors MLS}

  s.rubyforge_project = "mls"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Developoment 
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'sdoc'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'sdoc-templates-42floors'

  # Runtime
  s.add_runtime_dependency 'sunstone'
end

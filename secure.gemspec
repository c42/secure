# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "secure/version"

Gem::Specification.new do |s|
  s.name        = "secure"
  s.version     = Secure::VERSION
  s.authors     = ["Tejas Dinkar"]
  s.email       = ["tejas@gja.in"]
  s.homepage    = ""
  s.summary     = %q{gem to do things securely using ruby $SAFE}
  s.description = %q{see summary}

  s.rubyforge_project = "secure"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')
end

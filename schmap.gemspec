# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schmap/version"

Gem::Specification.new do |s|
  s.name        = "schmap"
  s.version     = Schmap::VERSION
  s.authors     = ["Duccio Giovannelli"]
  s.email       = ["giovannelli@extendi.it"]
  s.homepage    = ""
  s.description = %q{A Ruby interface to the Schmap API.}
  s.summary     = s.description
  s.test_files = Dir.glob("spec/**/*")
  s.rubyforge_project = "schmap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'yard'
  s.add_dependency "json"
  s.add_dependency "nokogiri"
  s.add_dependency "active_support"
  
end

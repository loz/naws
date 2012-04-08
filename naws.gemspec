# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "naws/version"

Gem::Specification.new do |s|
  s.name        = "naws"
  s.version     = NAWS::VERSION
  s.authors     = ["Jonathan Lozinski"]
  s.email       = ["jonathan.lozinski@sage.com"]
  s.homepage    = ""
  s.summary     = %q{NAWS - Not A WebServer}
  s.description = %q{Attempting to write a ruby rack compatable web server}

  s.rubyforge_project = "naws"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
  s.add_runtime_dependency "rack"
end

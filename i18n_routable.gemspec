# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "i18n_routable/version"

Gem::Specification.new do |s|
  s.name        = "i18n_routable"
  s.version     = I18nRoutable::VERSION
  s.authors     = ["Chase Stubblefield", "Thomas Shafer"]
  s.email       = ["tech_ops@change.org"]
  s.homepage    = "http://www.change.org"
  s.summary     = %q{Internationalized Routing}
  s.description = %q{This gem provides an easy way to translate your routes for your international market}

  s.rubyforge_project = "i18n_routable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", '>= 3.2.0'
  s.add_dependency 'i18n', '> 0.5', '!= 0.7'

  s.add_development_dependency "rspec", '~> 2.14.1'
  s.add_development_dependency "rspec-rails", '~> 2.14.1'
end

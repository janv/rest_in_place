# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rest_in_place/version"

Gem::Specification.new do |s|
  s.name        = "rest_in_place"
  s.version     = RestInPlace::VERSION
  s.date        = '2012-06-07'
  s.authors     = ["Jan Varwig"]
  s.email       = ["jan@varwig.org"]
  s.homepage    = "http://jan.varwig.org"
  s.summary     = %q{An AJAX Inplace-Editor for the Rails 3.1 asset pipeline.}
  s.description = %q{REST in Place is an AJAX Inplace-Editor that talks to RESTful controllers.}
  s.license     = "MIT"

  s.files       = Dir["Gemfile", "MIT-LICENSE", "README.markdown", "rest_in_place.gemspec", "lib/**/*"]

  s.require_paths = ["lib"]
  s.add_dependency('rails', '>= 3.1')
end

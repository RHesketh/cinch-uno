# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name                      = 'cinch-uno'
  s.version                   = '0.0.5'
  s.summary                   = 'A plugin that allows you to play the popular card game.'
  s.authors                   = ['Robert Hesketh']
  s.email                     = ['contact@robhesketh.com']
  s.homepage                  = 'http://github.com/RHesketh/cinch-uno'
  s.required_ruby_version     = '>= 1.9.1'
  s.files                     = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.add_dependency("cinch", "~> 2.0")
  s.add_development_dependency "rspec"
  s.add_development_dependency "cinch-test"

  s.license = "Unlicense"
end
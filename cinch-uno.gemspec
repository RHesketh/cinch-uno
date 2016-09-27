Gem::Specification.new do |s|
  s.name = 'cinch-uno'
  s.version = '0.0.3'
  s.summary = 'A plugin that allows you to play the popular card game.'
  s.description = s.summary
  s.authors = ['Robert Hesketh']
  s.email = ['contact@robhesketh.com']
  s.homepage = 'http://rubydoc.info/github/RHesketh/cinch-uno'
  s.required_ruby_version = '>= 1.9.1'
  s.files = Dir['LICENSE', 'README.md', '{lib,examples}/**/*']
  s.add_dependency("cinch", "~> 2.0")
  #s.add_dependency("nokogiri")
  s.license = "Unlicense"
end
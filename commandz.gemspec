require './lib/commandz/version'

Gem::Specification.new do |s|
  s.name        = 'commandz'
  s.version     = CommandZ::VERSION
  s.authors     = ['Etienne Lemay']
  s.email       = ['etienne@heliom.ca']
  s.homepage    = 'http://etiennelem.github.io/commandz'
  s.summary     = '⌘Z add commands history support to your web app'
  s.license     = 'MIT'

  s.files      = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(spec)/})

  s.add_development_dependency 'rake'
  s.add_development_dependency 'jasmine'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'sprockets'
  s.add_development_dependency 'jasmine-headless-webkit'
  s.add_development_dependency 'guard-jasmine-headless-webkit'
end

require_relative "lib/philote/version"

Gem::Specification.new do |s|
  s.name        = 'philote'
  s.version     = Philote::VERSION
  s.summary     = 'A philote websocket server admin/client library.'
  s.authors     = ['pote']
  s.email       = ['pote@tardis.com.uy']
  s.homepage    = 'https://github.com/pote/philote-rb'
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n")

  s.add_dependency "redic"
end

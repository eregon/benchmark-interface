require 'json'

Gem::Specification.new do |spec|
  spec.name          = 'benchmarkable'
  spec.version       = '0.1'
  spec.authors       = ['Chris Seaton']
  spec.email         = ['chris@chrisseaton.com']
  spec.summary       = 'One Ruby benchmarking interface to rule them all'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']
end

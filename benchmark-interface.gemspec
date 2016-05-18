require 'json'

Gem::Specification.new do |spec|
  spec.name          = 'benchmark-interface'
  spec.version       = '0.1'
  spec.authors       = ['Chris Seaton']
  spec.email         = ['chris@chrisseaton.com']
  spec.summary       = 'One Ruby benchmarking interface to rule them all'
  spec.description   = 'A new format for writing Ruby benchmarks, and a tool ' \
                       'that lets you run benchmarks written in many formats ' \
                       'with many different benchmarking tools'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
end

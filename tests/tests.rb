#!/usr/bin/env ruby

# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require 'fileutils'

version = RUBY_VERSION.split('.').first(2).map(&:to_i)
earlier_than_21 = version[0] < 2 || (version[0] == 2 && version[1] < 1)

regenerate = ARGV.delete('--regenerate')

examples = Dir.glob('examples/*.rb')
examples.delete('examples/clamp.rb')

if ARGV.empty?
  backends = ['--simple', '--bm', '--bmbm', '--bips']
else
  backends = ARGV
end

failed = false

test_example_backend = Proc.new do |example, backend, options|
  puts "#{example} #{backend} #{options}"
  
  expected_file = "tests/expected/#{File.basename(example, '.rb')}-#{backend[2..-1]}.txt"
  actual = `bin/benchmarkable #{example} #{backend} #{options} | tests/tools/squash.rb`
  
  if regenerate
    File.write expected_file, actual
  else
    expected = File.read expected_file
    if expected != actual
      puts 'not as expected!'
      puts 'expected:'
      puts expected
      puts 'actual:'
      puts actual
      failed = true
    end
  end
end

examples.each do |example|
  backends.each do |backend|
    if example == 'examples/mri.rb'
      test_example_backend.call example, backend, '' unless earlier_than_21
      
      begin
        FileUtils.cp 'tests/rewritten/mri.rb', 'mri-rewrite-cache.rb'
        test_example_backend.call example, backend, '--use-cache'
      ensure
        FileUtils.rm 'mri-rewrite-cache.rb'
      end
    else
      test_example_backend.call example, backend, ''
    end
  end
end

abort if failed

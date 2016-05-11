#!/usr/bin/env ruby

# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

regenerate = ARGV.delete('--regenerate')

examples = Dir.glob('examples/*.rb')
examples.delete('examples/clamp.rb')

if ARGV.empty?
  backends = ['--simple', '--bm', '--bmbm', '--bips']
else
  backends = ARGV
end

failed = false

examples.each do |example|
  backends.each do |backend|
    puts "#{example} #{backend}"
    
    expected_file = "tests/expected/#{File.basename(example, '.rb')}-#{backend[2..-1]}.txt"
    actual = `bin/benchmarkable #{example} #{backend} | tests/tools/squash.rb`
    
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
end

abort if failed

# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require 'benchmarkable/benchmark'
require 'benchmarkable/benchmark-set'
require 'benchmarkable/frontends/mri'
require 'benchmarkable/backends/simple'
require 'benchmarkable/backends/benchmark'
require 'benchmarkable/backends/bips'
require 'benchmarkable/backends/bench9000'
require 'benchmarkable/require'
require 'benchmarkable/run'

def benchmarkable(name=nil, &block)
  Benchmarkable::BenchmarkSet.current.register name, block
end

if $PROGRAM_NAME.split('/').last != 'benchmark'
  set = Benchmarkable::BenchmarkSet.new
  backend = Benchmarkable::Backends::Bips

  at_exit do
    set.prepare
    backend.run set, set.benchmarks, {}
  end
end

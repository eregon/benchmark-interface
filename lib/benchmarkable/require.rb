# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Kernel

  alias_method :benchmarkable_original_require, :require

  def require(feature)
    case feature
      when 'benchmark'
        benchmarkable_original_require 'benchmarkable/frontends/benchmark'
      when 'benchmark/ips'
        benchmarkable_original_require 'benchmarkable/frontends/bips'
      when 'rbench'
        benchmarkable_original_require 'benchmarkable/frontends/rbench'
      when 'perfer'
        benchmarkable_original_require 'benchmarkable/frontends/perfer'
      when 'bench9000/harness', 'bench9000/micro-harness'
        if caller_locations.any? { |l| l.path.include? 'lib/benchmarkable/backends/bench9000.rb' }
          # Do nothing
        elsif feature == 'bench9000/harness'
          benchmarkable_original_require 'benchmarkable/frontends/bench9000'
        elsif feature == 'bench9000/micro-harness'
          benchmarkable_original_require 'benchmarkable/frontends/bench9000micro'
        end
      when 'benchmarkable'
        # Already loaded by bin/benchmarkable
      else
        benchmarkable_original_require feature
    end
  end

end

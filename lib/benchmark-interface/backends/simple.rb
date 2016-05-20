# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module BenchmarkInterface
  module Backends
    module Simple

      def self.run(benchmark_set, names, options)
        full_time = options['--time']
        
        inner_iterations = benchmark_set.iterations
        
        benchmark_set.benchmarks(names).each do |benchmark|
          puts benchmark.name
          block = benchmark.block

          start_time = Time.now
          iterations = 1

          while Time.now - start_time < full_time
            start_round_time = Time.now
            iterations.times do
              block.call
            end
            round_time = Time.now - start_round_time

            if round_time == 0
              iterations *= 2
              next
            end

            if round_time < 0.01
              # If the round time was very low and so very imprecise then we may
              # get a wild number of iterations next time. Instead, just double
              # the number of iterations until it's at least a hundredth of a
              # second. Don't even print the result until then, as otherwise
              # without the extra round time information it could be misleading.
              iterations *= 2
            else
              # If the iteration time is at least a hundredth of a second, we
              # can print an ips and adjust for the next round to try to make
              # it take a second.
              ips = iterations / round_time
              puts ips * inner_iterations
              iterations = ips.to_i
              iterations = 1 if iterations < 1
            end
          end
        end
      end

    end
  end
end

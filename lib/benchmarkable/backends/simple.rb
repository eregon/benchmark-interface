# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Benchmarkable
  module Backends
    module Simple

      def self.run(benchmark_set, names, options)
        loop_time = 10
        
        options.each do |option, value|
          next if %w(--simple --use-cache).include?(option)
          begin
            loop_time = Integer(option[2..-1])
          rescue
          end
        end
        
        benchmark_set.benchmarks(names).each do |benchmark|
          puts benchmark.name
          block = benchmark.block

          start_time = Time.now

          while Time.now - start_time < loop_time
            start_iteration_time = Time.now
            iterations = 0
            while Time.now - start_iteration_time < 1
              block.call
              iterations += 1
            end
            iteration_time = Time.now - start_iteration_time
            iterations *= benchmark_set.iterations
            puts iterations / iteration_time
          end
        end
      end

    end
  end
end

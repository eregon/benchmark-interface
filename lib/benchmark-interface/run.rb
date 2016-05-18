# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module BenchmarkInterface

  NON_MRI_INDICATORS = %w(
    Benchmark.measure Benchmark.realtime Benchmark.benchmark Benchmark.bm
    Benchmark.bmbm RBench.run Benchmark.ips Perfer.session harness_sample
  )

  def self.run(args)
    set = BenchmarkInterface::BenchmarkSet.new

    backend = BenchmarkInterface::Backends::Bips
    names = []
    options = {}

    to_load = []

    args.each do |arg|
      if arg.start_with? '-'
        case arg
          when '--simple'
            backend = BenchmarkInterface::Backends::Simple
          when '--bips'
            backend = BenchmarkInterface::Backends::Bips
          when '--bm'
            backend = BenchmarkInterface::Backends::Bm
          when '--bmbm'
            backend = BenchmarkInterface::Backends::BmBm
          when '--bench9000'
            backend = BenchmarkInterface::Backends::Bench9000
          else
            options[arg] = true
        end
      elsif arg.include?('.rb')
        to_load.push arg
      else
        names.push arg
      end
    end

    to_load.each do |path|
      source = File.read(path)
      if NON_MRI_INDICATORS.any? { |t| source.include?(t) } || source =~ /benchmark(\s+do|{)/
        set.load_benchmarks path
      else
        set.load_mri_benchmarks path, options
      end
    end

    set.prepare

    if set.benchmarks.empty?
      abort 'No benchmarks found!'
    end

    names.each do |name|
      unless set.benchmark(name)
        abort "Unknown benchmark #{name}"
      end
    end

    names = set.benchmarks.map(&:name) if names.empty?

    backend.run set, names, options
  end

end

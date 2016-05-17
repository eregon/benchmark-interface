# Copyright (c) 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Benchmarkable
  
  class RBenchContext
    
    def initialize
      @columns = []
    end
    
    def format(options)
      # Ignore
    end
    
    def column(name, options=nil)
      singleton_class = (class << self; self end)
      singleton_class.class_eval "def #{name}(&block); rbench_benchmarkable #{name.inspect}, block; end"
      @columns.push name
    end
    
    def group(name)
      @group_name = name
      yield self
    ensure
      @group_name = nil
    end
    
    def report(name, &block)
      if @columns.size == 0
        Benchmarkable.benchmark name, &block
      else
        @report_name = name
        instance_eval &block
      end
    ensure
      @report_name = nil
    end
    
    def summary(title)
      # Ignore
    end
    
    def rbench_benchmarkable(column_name, block)
      name = [@group_name, @report_name, column_name].compact.join('-')
      Benchmarkable.benchmark name, &block
    end
    
  end
  
end

module RBench
  
  def self.run(count, &block)
    Benchmarkable::RBenchContext.new.instance_eval &block
  end
  
end

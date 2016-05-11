# Benchmarkable

## Introduction

Benchmarkable is one Ruby benchmarking interface to rule them all. It allows
you to run benchmarks written for one Ruby benchmarking system using some other
Ruby benchmarking system.

For example, Benchmarkable lets you take a benchmark from MRI's suite and run
it using `benchmark-ips`, or run a benchmark written using Bench9000 and run
it using `bmbm`.

Benchmarkable also provides a new format for writing benchmarks, which is
designed to be the simplest of all, making it easy to write lots of new
benchmarks and run them any way you like.

## Examples

### Running an MRI benchmark using `benchmark-ips`

```
$ benchmarkable ruby/benchmark/bm_vm1_length.rb

These are long benchmarks - we're increasing warmup and sample time
Warming up --------------------------------------
       bm_vm1_length     1.000  i/100ms
       bm_vm1_length     1.000  i/100ms
       bm_vm1_length     1.000  i/100ms
Calculating -------------------------------------
       bm_vm1_length      0.955  (± 0.0%) i/s -     10.000  in  10.472341s
       bm_vm1_length      0.960  (± 0.0%) i/s -     10.000  in  10.433246s
       bm_vm1_length      0.975  (± 0.0%) i/s -     10.000  in  10.260680s
```

### Running a `bench9000` benchmark using `bmbm`

```
$ benchmarkable bench9000/benchmarks/classic/mandelbrot.rb --bmbm

                 user     system      total        real
mandelbrot   1.760000   0.030000   1.790000 (  1.804423)
```

## The Benchmarkable Interface

Benchmarkable provides its own new format for writing benchmarks. It's very
simple.

```ruby
benchmarkable { 14 * 14 * 14 }
benchmarkable { 14 ** 3 }
```

You can give benchmarks names, and you usually should, but they will be named
with the file name and line number if you don't.

```ruby
benchmarkable('mul') { 14 * 14 * 14 }
benchmarkable('pow') { 14 ** 3 }
```

You just write that in the file. You don't need to require anything. We talk
about all the benchmarks in a file being the 'benchmark set'.

## Frontends

If you already have benchmarks written for a different system you can run those
with Benchmarkable.

Supported frontends are:

* Benchmarkable
* MRI's benchmarks
* `benchmark` (the standard `measure`, `bm`, `bmbm` methods and so on)
* RBench
* Perfer
* `benchmark-ips`
* `bench9000`

### Notes on specific frontends

#### Benchmarkable

As well as normal usage, you can also `require 'benchmarkable'` at the top of
your file of benchmarks, and then run the file as a normal Ruby script. This
will have the same effect as `benchmarkable file.rb` (and so will run
`benchmark-ips` as the backend).

#### MRI's benchmarks

For MRI's benchmarks we detect the last statement, which is usually a `while`
loop and wrap that in a Benchmarkable block. If we see a variable being
initialised and then used in the last statement, we copy that into the block.
This doesn't work in all cases, but it does in most. The `--show-rewrite` option
shows you what we are doing. Please file a bug if we're getting it wrong for any
benchmarks in the MRI repository.

Running MRI's benchmarks requires rewriting their source code, which means
running the fairly complex `parser` and `unparser` gems. This is a bit much to
ask of new Ruby implementations, so you can do the rewriting using another
implementation and get it to cache the result for the real implementation. The
file is written to `mri-rewrite-cache.rb` in the current directory.

```
$ rbenv shell 2.3.1
$ benchmarkable ruby/benchmark/bm_vm1_length.rb --cache
$ rbenv shell topaz-dev
$ benchmarkable ruby/benchmark/bm_vm1_length.rb --use-cache
```

#### `benchmark-ips` and Perfer

Both `benchmark-ips` and Perfer allow you to write benchmarked blocks which
take a number of iterations. This is done to reduce the overhead of calling
the block by putting the iterations loop (presumably a `while` loop, so not
itself involving another block) inside the benchmarked code. However this isn't
supported by other backends. To make this work, we look at how many iterations
are needed to make the benchmark run for about a second and always run that
many iterations. The number of iterations is the same for all benchmarks.

## Backends

When you have a file of benchmarks, you can run it using different Ruby
benchmarking systems. By default, it will run your benchmarks with
`benchmark/ips`, which is usually the best choice.

Supported backends are:

* Simple looping, via `--simple`
* `bm`, via `--bm`
* `bmbm`, via `--bm`
* `benchmark-ips`, via `--bips`
* `bench9000`, via `--bench9000`

### Notes on specific backends

#### Simple looping

Simple looping does the simplest thing possible and runs your benchmark in a
loop printing the iterations per second as it goes. By default it runs for
10s, but you can use options like `--60` to run for 60 seconds.

#### `bm` and `bmbm`

`bm` and `bmbm` only run your benchmark once when timing, which isn't what
benchmarks written for `benchmark-ips` expect. Therefore if a benchmark takes
less than a tenth of a second it is run several times so that it takes about a
second. The number of iterations is the same for all benchmarks in the same set
and is printed at the set starts.

You can turn this off with `--no-scale`

#### `benchmark-ips`

We run with `x.iterations = 3` by default.

If a benchmark takes more than a tenth of a second, the warmup and sampling
periods of `benchmark-ips` will be increased, as by default `benchmark-ips` is
set up for quicker benchmarks that complete many iterations in a second.

You can turn this off with `--no-scale`

#### `bench9000`

Using `bench9000` as a backend is a little more complex. You need to define a
configuration file which runs `benchmarkable` with the benchmark file, the
`--bench9000` flag and the name of the benchmark, and then you separately run
`bench9000`.

```
benchmark 'clamp_a', 'bin/benchmarkable examples/benchmarkable.rb --bench9000 clamp_a'
benchmark 'clamp_b', 'bin/benchmarkable examples/benchmarkable.rb --bench9000 clamp_b'
```

```
$ bench9000/bin/bench9000 detail --config bench9000.config 2.3.0 clamp_a clamp_b --value-per-line
```

The `bench9000` has the same scaling functionality as `bm`, but here it switches
to the micro-harness. Turn it off with `--no-scale`.

## Supported Ruby Implementations

Tested versions are in brackets. Earlier versions of the same major also
probably work fine.

* MRI
* JRuby
* JRuby+Truffle
* Rubinius
* Topaz

Benchmarkable is designed to be gentle on new implementations of Ruby and
should hopefully be relatively easy to get working if you are writing one.

## Caveats

* This tool does nothing to address the risk of inputs being constant folded or
results discarded.
* Don't compare results from two different benchmarking backends.
* Some automated things we do like scaling and setting iterations can
complicate benchmarking.
* Use your own scientific judgement!

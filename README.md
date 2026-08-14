# monotonic.rb


## Description

Create accurate timings of excution in Ruby.

What accurate means is to capture many digits as an operating system is willing to afford. Hence, the clock is read in nanoseconds by default. If a number in seconds is requested, then that is derived from nanoseconds rather than read directly, so the rounding happens upon request and not before.

It tells most upon an elapsed interval, that being the difference of two readings drawn from an uptime many orders of magnitude larger than itself. A `Float` carries a mantissa of fixed width wherever it sits, so its absolute resolution falls away as the uptime grows: around 2.2e-16s near 1.0, but only 4.7e-10s after a month of uptime. Differencing two exact integers spends none of the reading, however long the machine has been up.

Which clock is read follows from that. `Monotonic::Timer` measures intervals and so takes the finest available which holds while the machine sleeps, a closed lid being no part of execution: `CLOCK_UPTIME_RAW` upon Darwin, where it advances in some 42ns against the 1000ns of `CLOCK_MONOTONIC`, and `CLOCK_MONOTONIC` elsewhere, which upon Linux already holds while suspended and advances finely. `Monotonic::Time` is an instant rather than an interval, and `#to_time` maps it back onto the wall clock, so it stays upon `CLOCK_MONOTONIC`, sleep and all.

How finely a clock advances is the platform's business and not this library's to claim, so it is asked rather than tabulated:

```ruby
Monotonic::Timer.resolution
# => 42
Monotonic::Time.resolution
# => 1000
```

A reading is denominated in nanoseconds whether or not the clock affords it, so that is the method which says what a reading is worth. Two figures give the sense of it upon the finer clock: reading it costs about 34ns against the 42ns it takes to advance, the two being close enough that there is little to be had by going finer, and a pair of `Float`s would not begin to lose it until some six years of uptime — but they would begin.

Units and the arithmetic between them belong to [duration.rb](https://github.com/thoran/duration.rb), which this gem depends upon rather than reimplementing. An elapsed interval is a duration, so `Monotonic::Timer#to_duration` hands one back and every unit follows from it exactly, a Rational until `to_f` is asked for. An instant is not a duration: `Monotonic::Time#-` gives the duration between two instants, `#+` takes a duration and gives a later instant, and adding one instant to another raises — a quantity which moves when you move the epoch is not a quantity, and Ruby's own `Time` refuses it for the same reason.

What `Monotonic::Time` is for follows from that. It is the point type: `Monotonic::Timer` used it as its own substrate until 0.7.0, when the two took different clocks, and what remains to it is what a point is good for — the difference of two instants, which is the reason a monotonic clock is read at all, and `#to_time`, which places one against the wall clock by way of the boot time.

Where a timing is taken from can be chosen. `Monotonic::Timer.new` reads the clock directly, as it always has and much the cheapest; `Monotonic::Timer.new(instants: Monotonic::Time)` times upon `CLOCK_MONOTONIC` instead, coarser but placeable against the wall clock. Anything answering `.now` will do.

```ruby
timer = Monotonic::Timer.new(instants: Monotonic::Time)
timer.start; sleep 0.002; timer.stop
timer.total_nanoseconds
# => 2508000, upon a clock which ticks in whole microseconds
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monotonic.rb'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install monotonic.rb
```


## Usage

### Monotonic::Time

```ruby
require 'monotonic.rb'

monotonic_time = Monotonic::Time.new
monotonic_time.nanoseconds_since_boot
# => 2614365376498000

monotonic_time.seconds_since_boot
# => 1208799.325906

monotonic_time + Duration::Seconds.new(30)
# => #<Monotonic::Time>, thirty seconds later

Monotonic::Time.now - monotonic_time
# => #<Duration::Nanoseconds @nanoseconds=44104999>

monotonic_time + Monotonic::Time.now
# => TypeError: an instant plus an instant is not an instant

monotonic_time.to_s
# => "1164320.268127 seconds since boot."

monotonic_time.to_time
# => 2021-06-07 09:27:08 8249692651179/8388608000000 +1000
```

### Monotonic::Timer without a block

```ruby
require 'monotonic.rb'

timer = Monotonic::Timer.new
timer.start
i = 0
1_000_000.times{puts i += 1}
timer.stop
timer.total_nanoseconds
# => 27734000

timer.to_duration
# => #<Duration::Nanoseconds @nanoseconds=27734000>

timer.to_duration.to_microseconds.to_f
# => 27734.0

timer.total_time
# => 0.027734
```

### Monotonic::Timer with a block

```ruby
require 'monotonic.rb'

time = Monotonic::Timer.time do
  i = 0
  1_000_000.times{puts i += 1}
end
time
# => 6.975823000073433
```

### Monotonic::Timer with a block and block variable

```ruby
require 'monotonic.rb'
time = Monotonic::Timer.time do |timer|
  i = 0
  500_000.times{puts i += 1}
  p timer.total_time
  500_000.times{puts i += 1}
end
time
# => 6.975823000073433
```

### Monotonic::Timer with a block on a timer instance

```ruby
require 'monotonic.rb'
timer = Monotonic::Timer.new
time = timer.time do
  i = 0
  1_000_000.times{puts i += 1}
end
time
# => 7.033131000120193
```


## Contributing

1. Fork it ( https://github.com/thoran/monotonic.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

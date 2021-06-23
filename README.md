# monotonic.rb

## Description

Create accurate timings of excution in Ruby.

## Installation

Add this line to your application's Gemfile:
```ruby
  gem 'monotonic'
```
And then execute:
```bash
  $ bundle
```
Or install it yourself as:
```bash
  $ gem install monotonic.rb
```

## Usage

### MonotonicTime

```ruby
  require 'monotonic.rb'
  monotonic_time = Monotonic::Time.new
  monotonic_time.seconds_since_boot
  # => 1208799.325906
  monotonic_time + Monotonic::Time.now
  # => 2417598.681896
  monotonic_time - Monotonic::Time.now
  # => -0.044104999862611294
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
  timer.total_time
  # => 7.166559999808669
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

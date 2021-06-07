# CHANGELOG

## 0.5.0 (20210607): Added timing block on an instance of MonotonicTimer
+ MonotonicTime#+
+ MonotonicTime#-
~ MonotonicTimer#start: - use of MonotonicTime#to_time (using MonotonicTime#- instead)
~ MonotonicTimer#stop: - use of MonotonicTime#to_time (using MonotonicTime#- instead)
+ MonotonicTimer#time

## 0.4.1 (20210607): Fixed starting and stopping
- MonotonicTimer#initialize: - @total_time as it just made things more complicated unless needing splits
~ MonotonicTimer#start: - @start_monotonic_time as it wasn't really needed
~ MonotonicTimer#stop: - @stop_monotonic_time as it wasn't really needed
~ MonotonicTimer#total_time: - @total_time as it just made things more complicated unless needing splits

## 0.4.0 (20210606): Named Monotony and prepped as a gem.
/monotonic_time.rb/MonotonicTime.rb/
/monotonic_timer.rb/MonotonicTimer.rb/
+ Monotony namespace
+ monotony.gemspec

## 0.3.0 (20210604)
~ MonotonicTimer.time, so that it returns the total time to the value of the block
+ ./test/monotonic_time_test.rb
~ ./test/monotonic_timer_test.rb

## 0.2.0 (20210510): Added somewhat proper testing
+ ./test/monotonic_timer_test.rb
~ ./lib/monotonic_timer.rb: - self-run section test

## 0.1.1 (20200510)
~ ./lib/monotonic_timer.rb: + self-run section test

## 0.1.0 (20200115): Added classes for better structure
+ MonotonicTime
+ MonotonicTimer

## 0.0.0 (20200115)
+ timer()

# monotonic_timer.rb
# MonotonicTimer

# 20210604
# 0.3.0

require_relative './monotonic_time'

class MonotonicTimer

  class << self

    def time
      monotonic_timer = MonotonicTimer.new
      monotonic_timer.start
      yield monotonic_timer
      monotonic_timer.total_time
    ensure
      monotonic_timer.stop
    end

  end # class << self

  def initialize
    @total_time = 0
  end

  def start
    @start_monotomic_time = MonotonicTime.now
    @start_time = @start_monotomic_time.to_time
  end

  def stop
    @stop_monotonic_time = MonotonicTime.now
    @finish_time = @stop_monotonic_time.to_time
    @total_time += (@finish_time - @start_time)
  end

  def total_time
    monotonic_time_now = MonotonicTime.now
    @total_time + (monotonic_time_now.to_time - @start_time)
  end

end

# monotonic_timer.rb
# MonotonicTimer

# 20210510
# 0.1.1

require_relative './monotonic_time'

class MonotonicTimer

  class << self

    def time
      monotonic_timer = MonotonicTimer.new
      monotonic_timer.start
      yield monotonic_timer
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

if __FILE__ == $0
  MonotonicTimer.time do |timer|
    sleep 1
    print(timer.total_time.round == 1 ? '.' : 'x')
    timer.stop
    print(timer.total_time.round == 2 ? '.' : 'x')
    sleep 1
    print(timer.total_time.round == 3 ? '.' : 'x')
    timer.start
    print(timer.total_time.round == 1 ? '.' : 'x')
    puts
  end
end

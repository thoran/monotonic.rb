# Monotony/MonotonicTimer.rb
# Monotony::MonotonicTimer

require_relative './MonotonicTime'

module Monotony
  class MonotonicTimer

    class << self

      def time
        monotonic_timer = MonotonicTimer.new
        monotonic_timer.start
        yield monotonic_timer
      ensure
        monotonic_timer.stop
        monotonic_timer.total_time
      end

    end # class << self

    def start
      @finish_time = nil
      @start_time = MonotonicTime.now
    end

    def stop
      @finish_time = MonotonicTime.now
    end

    def total_time
      if @finish_time
        @finish_time - @start_time
      else
        MonotonicTime.now - @start_time
      end
    end

    def time
      start
      yield self
    ensure
      stop
      total_time
    end

  end
end

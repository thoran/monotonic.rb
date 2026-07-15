# Monotonic/Timer.rb
# Monotonic::Timer

require_relative './Time'

module Monotonic
  class Timer

    class << self

      def time(&block)
        timer = Timer.new
        timer.time(&block)
      end

    end # class << self

    def start
      @finish_time = nil
      @start_time = Monotonic::Time.now
    end

    def stop
      @finish_time = Monotonic::Time.now
    end

    def total_time
      if @finish_time
        @finish_time - @start_time
      else
        Monotonic::Time.now - @start_time
      end
    end

    def time
      start
      yield self
    ensure
      stop
      return total_time
    end

  end
end

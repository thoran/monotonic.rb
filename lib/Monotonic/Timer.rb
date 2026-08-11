# Monotonic/Timer.rb
# Monotonic::Timer

require_relative './Time'

module Monotonic
  class Timer
    class << self
      # An interval is not an instant, and wants a different clock.  Upon Darwin
      # CLOCK_UPTIME_RAW advances in some 42ns against the 1000ns of
      # CLOCK_MONOTONIC, and holds while the machine sleeps, which is the right
      # answer for a timed block: a closed lid is not execution.  Linux has no
      # such clock, but its CLOCK_MONOTONIC already holds while suspended and
      # advances finely, so the fallback carries the same meaning and not merely
      # the same name.
      #
      # Which clocks exist is the platform's business, so this is asked rather
      # than declared, as .resolution is.
      def clock_name
        @clock_name ||= %i[CLOCK_UPTIME_RAW CLOCK_MONOTONIC].find{|name| Process.const_defined?(name)}
      end

      def time(&block)
        timer = Timer.new
        timer.time(&block)
      end

      # How finely this clock advances, in nanoseconds.  Asked of the platform
      # rather than claimed by the library, and worth asking: a reading is
      # denominated in nanoseconds whether the clock affords them or not.
      def resolution
        Process.clock_getres(CLOCK, :nanosecond)
      end
    end # class << self

    # Read twice upon every measurement, against a floor of some tens of
    # nanoseconds, so this is the one place here where a constant is worth the
    # rigidity: a method call would be a measurable part of what it measures.
    # It follows .clock_name, and so must come after it.
    CLOCK = Process.const_get(clock_name)

    def start
      @finish_nanoseconds = nil
      @start_nanoseconds = now
    end

    def stop
      @finish_nanoseconds = now
    end

    # Two exact integers differenced, which spends none of the reading.  A pair
    # of Floats would not begin to lose the clock at this resolution until some
    # six years of uptime, but they would begin.
    def total_nanoseconds
      finish_nanoseconds - @start_nanoseconds
    end

    def total_time
      total_nanoseconds / NANOSECONDS_PER_SECOND.to_f
    end

    def time
      start
      begin
        yield self
      ensure
        stop
      end
      total_time
    end

    private

    # A timer which has not been stopped is still running, so the finish is now.
    def finish_nanoseconds
      @finish_nanoseconds || now
    end

    def now
      Process.clock_gettime(CLOCK, :nanosecond)
    end
  end
end

# Monotonic/Timer.rb
# Monotonic::Timer

require 'duration.rb'
require_relative './Measurement'

module Monotonic
  class Timer
    # An interval is not an instant, and wants a different clock.  Upon Darwin
    # CLOCK_UPTIME_RAW advances in some 42ns against the 1000ns of
    # CLOCK_MONOTONIC, and holds while the machine sleeps, which is the right
    # answer for a timed block: a closed lid is not execution.  Linux has no such
    # clock, but its CLOCK_MONOTONIC already holds while suspended and advances
    # finely, so the fallback carries the same meaning and not merely the same
    # name.  This is what would be accepted, in order; which of them exists is
    # the platform's business, and .clock_name reports what was found.
    CLOCK_NAMES = %i[CLOCK_UPTIME_RAW CLOCK_MONOTONIC]

    # Read twice upon every measurement, against a floor of some tens of
    # nanoseconds, so this is the one place here where a constant is worth the
    # rigidity: a method call would be a measurable part of what it measures.
    CLOCK = Process.const_get(CLOCK_NAMES.find{|name| Process.const_defined?(name)})

    # How many measurements of nothing .floor takes, and which of them it keeps.
    SAMPLES = 1_000
    PERCENTILE = 0.95

    class << self
      def clock_name
        @clock_name ||= CLOCK_NAMES.find{|name| Process.const_defined?(name)}
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

      # What it costs to measure at all, in nanoseconds, measured by timing
      # measurements of nothing.  The clock's tick is not the limit: two readings
      # must be taken, and taking them takes time, so an interval near this
      # figure is mostly the measuring.
      #
      # It is a floor and not an error bar.  The typical cost is a tick or two;
      # the tail is unbounded and one-sided, since the scheduler may take the
      # processor away between the two readings and no single measurement can
      # detect that it did.  A high percentile is taken rather than a median, so
      # that the ordinary case is covered rather than merely the best one.
      # Repeat and take a robust statistic if the tail matters.
      def floor
        @floor ||= (
          samples = SAMPLES.times.map{timer = new; timer.start; timer.stop; timer.total_nanoseconds}.sort
          samples[(samples.length * PERCENTILE).to_i]
        )
      end
    end # class << self

    # Where the instants come from.  Nothing supplied means the clock is read
    # directly, which is what this has always done and is much the cheapest: a
    # raw reading costs some 57ns against the 171ns of making a Monotonic::Time,
    # and two are taken per measurement.
    #
    # Supplying Monotonic::Time times upon CLOCK_MONOTONIC instead — coarser, at
    # 1000ns against 42ns, but it maps back onto the wall clock, so a timing can
    # be placed as well as measured.  Anything answering .now will do, its
    # instants needing only to subtract to something which can say itself in
    # nanoseconds.  That is what 0.7.0 took away without saying so, Timer having
    # read Monotonic::Time until the two took different clocks.
    def initialize(instants: nil)
      @instants = instants
    end

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
    #
    # Raw readings difference to nanoseconds already.  Instants difference to
    # whatever their own subtraction gives, so it is asked to say itself in
    # nanoseconds — which is why this could not be done before 0.8.0, where
    # Monotonic::Time#- began answering with a duration rather than a bare Float
    # of seconds.
    def total_nanoseconds
      elapsed = finish_nanoseconds - @start_nanoseconds
      elapsed.respond_to?(:to_nanoseconds) ? elapsed.to_nanoseconds.to_i : elapsed
    end

    # An elapsed interval is a duration, so here is one, and every unit follows
    # from it exactly.  #total_time is the same figure in seconds, that being
    # the unit this library has always answered in.
    def to_duration
      Duration::Nanoseconds.new(total_nanoseconds)
    end

    def total_time
      to_duration.to_seconds.to_f
    end

    # The elapsed interval together with what it is worth.  Not memoized: a timer
    # which has not been stopped is still running, and so is its measurement.
    # The floor is handed over as a method rather than a figure, so that a caller
    # which only ever wants a number never sets the thousand null measurements
    # going.
    def measurement(drift: nil)
      Monotonic::Measurement.new(total_nanoseconds, floor: self.class.method(:floor), drift: drift)
    end

    def to_s
      measurement.to_s
    end

    # A Monotonic::Measurement rather than a bare Float, so that what comes back
    # says how much of itself is real.  #total_time and #total_nanoseconds are
    # still there for a number.
    def time
      start
      begin
        yield self
      ensure
        stop
      end
      measurement
    end

    private

    # A timer which has not been stopped is still running, so the finish is now.
    def finish_nanoseconds
      @finish_nanoseconds || now
    end

    def now
      @instants ? @instants.now : Process.clock_gettime(CLOCK, :nanosecond)
    end
  end
end

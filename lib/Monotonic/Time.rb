# Monotonic/Time.rb
# Monotonic::Time

require 'sys-uptime'

module Monotonic
  NANOSECONDS_PER_SECOND = 1_000_000_000

  class Time
    class << self
      # An instant, which #to_time maps back onto the wall clock by way of the
      # boot time, so the clock wanted here is the one which tracks time since
      # boot as the wall clock understands it.  That is CLOCK_MONOTONIC, sleep
      # and all.  Monotonic::Timer measures intervals rather than instants and
      # chooses a finer clock of its own.
      #
      # Unlike Timer's, this one is chosen rather than found, there being no
      # alternative which would still answer to #to_time.  It is a method all
      # the same, so that the two classes answer the question alike.
      def clock_name
        :CLOCK_MONOTONIC
      end

      def now
        self.new
      end

      # How finely this clock advances, in nanoseconds.  It is asked rather than
      # tabulated, being a property of the processor and the operating system
      # and not of this library: upon macOS CLOCK_MONOTONIC answers 1000 here.
      # A reading is denominated in nanoseconds whatever the answer, so this is
      # the method which says what a reading is worth.
      def resolution
        Process.clock_getres(CLOCK, :nanosecond)
      end
    end # class << self

    # Read upon every instance, so a constant rather than a lookup.  It follows
    # .clock_name, and so must come after it.
    CLOCK = Process.const_get(clock_name)

    attr_reader :nanoseconds_since_boot

    # The clock is read in nanoseconds because it answers there with an Integer,
    # which is exact and stays exact however long the machine has been up.
    # Seconds are derived rather than read, so that the reading loses nothing and
    # the rounding happens where it is asked for.
    def seconds_since_boot
      @nanoseconds_since_boot / NANOSECONDS_PER_SECOND.to_f
    end

    def initialize
      @boot_time = Sys::Uptime.boot_time
      @nanoseconds_since_boot = Process.clock_gettime(CLOCK, :nanosecond)
    end

    def +(monotonic_time_addend)
      seconds_since_boot + monotonic_time_addend.seconds_since_boot
    end

    def -(monotonic_time_subtrahend)
      seconds_since_boot - monotonic_time_subtrahend.seconds_since_boot
    end

    def to_s
      "#{seconds_since_boot} seconds since boot."
    end

    def to_time
      @boot_time + seconds_since_boot
    end
  end
end

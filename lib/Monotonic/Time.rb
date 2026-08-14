# Monotonic/Time.rb
# Monotonic::Time

require 'duration.rb'
require 'sys-uptime'

module Monotonic
  class Time
    # An instant, which #to_time maps back onto the wall clock by way of the
    # boot time, so the clock wanted here is the one which tracks time since
    # boot as the wall clock understands it.  That is CLOCK_MONOTONIC, sleep and
    # all.  Monotonic::Timer measures intervals rather than instants and chooses
    # a finer clock of its own.
    #
    # Unlike Timer's, this one is chosen rather than found, there being no
    # alternative which would still answer to #to_time.  .clock_name is a method
    # all the same, so that the two classes answer the question alike.
    CLOCK = Process::CLOCK_MONOTONIC

    class << self
      def clock_name
        :CLOCK_MONOTONIC
      end

      def now
        self.new
      end

      # How finely this clock advances, in nanoseconds.  It is asked rather than
      # tabulated, being a property of the processor and the operating system
      # and not of this library: upon macOS CLOCK_MONOTONIC answers 1000 here.
      def resolution
        Process.clock_getres(CLOCK, :nanosecond)
      end
    end # class << self

    attr_reader :nanoseconds_since_boot

    # The clock is read in nanoseconds because it answers there with an Integer,
    # which is exact and stays exact however long the machine has been up.
    # Seconds are derived rather than read, so that the reading loses nothing and
    # the rounding happens where it is asked for.
    def seconds_since_boot
      Duration::Nanoseconds.new(@nanoseconds_since_boot).to_seconds.to_f
    end

    def initialize(nanoseconds_since_boot = Process.clock_gettime(CLOCK, :nanosecond))
      @nanoseconds_since_boot = nanoseconds_since_boot
    end

    # One question tells the two cases apart, and it is asked of the object
    # rather than of its class: does this know where it sits since boot?  If it
    # does it is an instant, and if it converts to nanoseconds it is a duration.
    # Nothing here names a class, so anything answering the same messages will
    # do.
    #
    # An instant plus a duration is an instant.  An instant plus an instant is
    # nothing at all: it depends upon where the epoch was arbitrarily put, and a
    # quantity which moves when you move the origin is not a quantity.  Ruby's
    # own Time refuses it, with "time + time?", and so does this.  The refusal is
    # asked of the duck too, since leaving it to Monotonic::Time happening not to
    # answer #to_nanoseconds would be an accident rather than a rule.
    def +(addend)
      if addend.respond_to?(:nanoseconds_since_boot)
        raise TypeError, "can't add #{addend.class} to #{self.class}: an instant plus an instant is not an instant"
      end
      unless addend.respond_to?(:to_nanoseconds)
        raise TypeError, "can't add #{addend.class} to #{self.class}: expected something answering to #to_nanoseconds"
      end
      self.class.new(@nanoseconds_since_boot + addend.to_nanoseconds.to_i)
    end

    # Minus an instant it is the duration between them; minus a duration it is
    # the earlier instant.  The first is why a monotonic clock is read at all.
    def -(subtrahend)
      if subtrahend.respond_to?(:nanoseconds_since_boot)
        Duration::Nanoseconds.new(@nanoseconds_since_boot - subtrahend.nanoseconds_since_boot)
      elsif subtrahend.respond_to?(:to_nanoseconds)
        self.class.new(@nanoseconds_since_boot - subtrahend.to_nanoseconds.to_i)
      else
        raise TypeError, "can't subtract #{subtrahend.class} from #{self.class}: expected an instant, or something answering to #to_nanoseconds"
      end
    end

    def to_s
      "#{seconds_since_boot} seconds since boot."
    end

    # The boot time is asked for here rather than kept upon every instant.  It
    # cost 1740ns of the 1947ns an instant took to make, and only this method
    # wants it — so an instant is now cheap to take, and the mapping still
    # uses the boot time as it stands rather than as it stood, Darwin moving
    # kern.boottime as the wall clock is disciplined.
    def to_time
      Sys::Uptime.boot_time + seconds_since_boot
    end
  end
end

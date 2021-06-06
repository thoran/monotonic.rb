# Monotony/MonotonicTime.rb
# Monotony::MonotonicTime

require 'sys-uptime'

module Monotony
  class MonotonicTime

    class << self

      def now
        self.new
      end

    end # class << self

    def initialize
      @boot_time = Sys::Uptime.boot_time
      @seconds_since_boot = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def to_s
      "#{@seconds_since_boot} seconds since boot."
    end

    def to_time
      @boot_time + @seconds_since_boot
    end

  end
end
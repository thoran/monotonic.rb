# 20200115

require 'sys-uptime'

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

p monotonic_time = MonotonicTime.now
p monotonic_time.to_time
p monotonic_time.to_s

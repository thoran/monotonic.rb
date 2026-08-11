require_relative '../../lib/Monotonic/Time'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotonic::Time do
  subject{Monotonic::Time.now}

  describe "#initialize" do
    it "the time spent in the block is returned as the value of the block" do
      expect(subject.instance_variable_get(:@boot_time)) \
        .must_equal(Sys::Uptime.boot_time)
    end

    it "the reading is taken from the monotonic clock in nanoseconds" do
      expect((subject.instance_variable_get(:@nanoseconds_since_boot) / 1_000_000_000.0).round(2)) \
        .must_equal((Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) / 1_000_000_000.0).round(2))
    end
  end

  describe ".clock_name" do
    it "is the clock which tracks time since boot as the wall clock understands it" do
      expect(Monotonic::Time.clock_name).must_equal(:CLOCK_MONOTONIC)
    end

    it "names the clock which is read" do
      expect(Monotonic::Time::CLOCK).must_equal(Process.const_get(Monotonic::Time.clock_name))
    end
  end

  describe ".resolution" do
    it "returns how finely the clock advances, in nanoseconds" do
      expect(Monotonic::Time.resolution) \
        .must_equal(Process.clock_getres(Process::CLOCK_MONOTONIC, :nanosecond))
    end

    it "returns an instance of integer" do
      expect(Monotonic::Time.resolution.class).must_equal(Integer)
    end
  end

  describe "#nanoseconds_since_boot" do
    it "returns an instance of integer" do
      expect((subject.nanoseconds_since_boot).class).must_equal(Integer)
    end
  end

  describe "#seconds_since_boot" do
    it "returns an instance of float" do
      expect((subject.seconds_since_boot).class).must_equal(Float)
    end

    it "is the nanoseconds reading expressed in seconds" do
      expect(subject.seconds_since_boot).must_equal(subject.nanoseconds_since_boot / 1_000_000_000.0)
    end
  end

  describe "#+" do
    it "returns an instance of string" do
      expect((subject + Monotonic::Time.now).class).must_equal(Float)
    end
  end

  describe "#-" do
    it "returns an instance of time" do
      expect((subject - Monotonic::Time.now).class).must_equal(Float)
    end
  end

  describe "#to_s" do
    it "returns an instance of string" do
      expect(subject.to_s.class).must_equal(String)
    end
  end

  describe "#to_time" do
    it "returns an instance of time" do
      expect(subject.to_time.class).must_equal(Time)
    end
  end
end

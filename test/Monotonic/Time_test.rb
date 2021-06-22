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

    it "the time spent in the block is returned as the value of the block" do
      expect(subject.instance_variable_get(:@seconds_since_boot).round(2)) \
        .must_equal(Process.clock_gettime(Process::CLOCK_MONOTONIC).round(2))
    end
  end

  describe "#seconds_since_boot" do
    it "returns an instance of string" do
      expect((subject.seconds_since_boot).class).must_equal(Float)
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

require_relative '../../lib/Monotonic/Timer'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotonic::Timer do
  context "with a block" do
    it "the time spent in the block is returned as the value of the block" do
      block_time = Monotonic::Timer.time do |timer|
        sleep 3
      end
      expect(block_time.to_duration.to_seconds.to_f.round).must_equal(3)
    end

    # Test introduced in 0.6.5 to demonstrate that the bug had been fixed.
    it "the time spent in the block is returned as the value of the block and not a value at the end of the block" do
      block_time = Monotonic::Timer.time do |timer|
        sleep 3
        4
      end
      expect(block_time.to_duration.to_seconds.to_f.round).must_equal(3)
    end

    # Test introduced in 0.6.7 to demonstrate that the bug had been fixed.
    it "an exception raised within the block is not swallowed" do
      expect{Monotonic::Timer.time{raise(ArgumentError)}}.must_raise(ArgumentError)
    end

    it "allows the timer to be started and stopped within the block" do
      Monotonic::Timer.time do |timer|
        sleep 1
        expect(timer.total_time.round).must_equal(1)
        timer.stop
        expect(timer.total_time.round).must_equal(1)
        timer.start
        expect(timer.total_time.round).must_equal(0)
        sleep 1
        expect(timer.total_time.round).must_equal(1)
        sleep 1
        expect(timer.total_time.round).must_equal(2)
        timer.start
        expect(timer.total_time.round).must_equal(0)
      end
    end

    it "alters the block time if it is started and stopped within the block" do
      block_time = Monotonic::Timer.time do |timer|
        sleep 1
        timer.stop
        sleep 1
        timer.start
        sleep 1
      end
      expect(block_time.to_duration.to_seconds.to_f.round).must_equal(1)
    end
  end

  context "without a block" do
    it 'works' do
      timer = Monotonic::Timer.new
      timer.start
      sleep 1
      expect(timer.total_time.round).must_equal(1)
      timer.stop
      expect(timer.total_time.round).must_equal(1)
      timer.start
      expect(timer.total_time.round).must_equal(0)
      sleep 1
      expect(timer.total_time.round).must_equal(1)
      sleep 1
      expect(timer.total_time.round).must_equal(2)
      timer.start
      expect(timer.total_time.round).must_equal(0)
    end
  end

  context "with a block on an timer instance" do
    it 'works' do
      timer = Monotonic::Timer.new
      time = timer.time do |timer|
        sleep 1
        expect(timer.total_time.round).must_equal(1)
        timer.stop
        expect(timer.total_time.round).must_equal(1)
        sleep 1
        expect(timer.total_time.round).must_equal(1)
        timer.start
        expect(timer.total_time.round).must_equal(0)
        sleep 1
      end
      expect(time.to_duration.to_seconds.to_f.round).must_equal(1)
      expect(timer.total_time.round).must_equal(1)
    end

    # Test introduced in 0.6.7 to demonstrate that the time up to an
    # interruption is not left running.
    it "the time up to an interruption remains available from the timer" do
      timer = Monotonic::Timer.new
      begin
        timer.time do
          sleep 1
          raise(ArgumentError)
        end
      rescue ArgumentError
      end
      sleep 1
      expect(timer.total_time.round).must_equal(1)
    end
  end

  context "the clock" do
    it "is the finest available which holds while the machine sleeps" do
      expect(Monotonic::Timer.clock_name) \
        .must_equal(Process.const_defined?(:CLOCK_UPTIME_RAW) ? :CLOCK_UPTIME_RAW : :CLOCK_MONOTONIC)
    end

    it "is asked of the platform rather than declared" do
      expect(Monotonic::Timer::CLOCK).must_equal(Process.const_get(Monotonic::Timer.clock_name))
    end

    it "reports its resolution rather than leaving it to be assumed" do
      expect(Monotonic::Timer.resolution) \
        .must_equal(Process.clock_getres(Monotonic::Timer::CLOCK, :nanosecond))
    end

    it "is no coarser than the one Monotonic::Time reads" do
      expect(Monotonic::Timer.resolution).must_be :<=, Monotonic::Time.resolution
    end
  end

  context "where the instants come from" do
    it "reads the clock directly when nothing is supplied" do
      timer = Monotonic::Timer.new
      timer.start
      timer.stop
      expect(timer.total_nanoseconds.class).must_equal(Integer)
    end

    it "takes them from whatever is supplied, in nanoseconds still" do
      timer = Monotonic::Timer.new(instants: Monotonic::Time)
      timer.start
      sleep 0.01
      timer.stop
      expect(timer.total_nanoseconds.class).must_equal(Integer)
      expect(timer.total_nanoseconds).must_be :>, 5_000_000
    end

    it "times upon that source's clock rather than its own" do
      timer = Monotonic::Timer.new(instants: Monotonic::Time)
      timer.start
      sleep 0.01
      timer.stop
      expect(timer.total_nanoseconds % Monotonic::Time.resolution).must_equal(0)
    end
  end

  context "as a duration" do
    it "hands back a Duration::Nanoseconds" do
      timer = Monotonic::Timer.new
      timer.start
      timer.stop
      expect(timer.to_duration.class).must_equal(Duration::Nanoseconds)
    end

    it "carries the same figure as #total_nanoseconds" do
      timer = Monotonic::Timer.new
      timer.start
      sleep 0.01
      timer.stop
      expect(timer.to_duration.to_i).must_equal(timer.total_nanoseconds)
    end

    it "converts exactly, #total_time being the same in seconds" do
      timer = Monotonic::Timer.new
      timer.start
      sleep 0.01
      timer.stop
      expect(timer.to_duration.to_seconds.to_f).must_equal(timer.total_time)
    end
  end

  context "in nanoseconds" do
    it "returns an instance of integer" do
      timer = Monotonic::Timer.new
      timer.start
      sleep 1
      timer.stop
      expect(timer.total_nanoseconds.class).must_equal(Integer)
    end

    it "is the total time expressed in nanoseconds" do
      timer = Monotonic::Timer.new
      timer.start
      sleep 1
      timer.stop
      expect(timer.total_nanoseconds / 1_000_000_000.0).must_equal(timer.total_time)
    end

    it "holds while the timer is stopped and runs on while it is not" do
      timer = Monotonic::Timer.new
      timer.start
      timer.stop
      held = timer.total_nanoseconds
      sleep 1
      expect(timer.total_nanoseconds).must_equal(held)
      timer.start
      expect(timer.total_nanoseconds).must_be :>, 0
    end
  end
end

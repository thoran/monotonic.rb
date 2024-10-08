require_relative '../../lib/Monotonic/Timer'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotonic::Timer do
  context "with a block" do
    it "the time spent in the block is returned as the value of the block" do
      block_time = Monotonic::Timer.time do |timer|
        sleep 3
      end
      expect(block_time.round).must_equal(3)
    end

    # Test introduced in 0.6.5 to demonstrate that the bug had been fixed.
    it "the time spent in the block is returned as the value of the block and not a value at the end of the block" do
      block_time = Monotonic::Timer.time do |timer|
        sleep 3
        4
      end
      expect(block_time.round).must_equal(3)
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
      expect(block_time.round).must_equal(1)
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
      expect(time.round).must_equal(1)
      expect(timer.total_time.round).must_equal(1)
    end
  end
end

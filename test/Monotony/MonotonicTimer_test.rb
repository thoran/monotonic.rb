require_relative '../../lib/Monotony/MonotonicTimer'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotony::MonotonicTimer do
  context "with a block" do
    it "the time spent in the block is returned as the value of the block" do
      block_time = Monotony::MonotonicTimer.time do |timer|
        sleep 3
      end
      expect(block_time.round).must_equal(3)
    end

    it "allows the timer to be started and stopped within the block" do
      Monotony::MonotonicTimer.time do |timer|
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
      block_time = Monotony::MonotonicTimer.time do |timer|
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
      timer = Monotony::MonotonicTimer.new
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
      timer = Monotony::MonotonicTimer.new
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

require_relative '../lib/monotonic_timer'

require 'minitest/autorun'
require 'minitest-spec-context'

describe MonotonicTimer do
  context "with a block" do
    it "the time spent in the block is returned as the value of the block" do
      block_time = MonotonicTimer.time do |timer|
        sleep 3
      end
      expect(block_time.round).must_equal(3)
    end

    it "allows the timer to be started and stopped within the block" do
      MonotonicTimer.time do |timer|
        sleep 1
        expect(timer.total_time.round).must_equal(1)
        timer.stop
        expect(timer.total_time.round).must_equal(2)
        sleep 1
        expect(timer.total_time.round).must_equal(3)
        timer.start
        expect(timer.total_time.round).must_equal(1)
      end
    end

    it "alters the block time if it is started and stopped within the block" do
      block_time = MonotonicTimer.time do |timer|
        sleep 1
        timer.stop
        sleep 1
        timer.start
      end
      expect(block_time.round).must_equal(1)
    end
  end

  context "without a block" do
    it 'works' do
      timer = MonotonicTimer.new
      timer.start
      sleep 1
      expect(timer.total_time.round).must_equal(1)
      timer.stop
      expect(timer.total_time.round).must_equal(2)
      sleep 1
      expect(timer.total_time.round).must_equal(3)
      timer.start
      expect(timer.total_time.round).must_equal(1)
    end
  end
end

require_relative '../lib/monotonic_timer'

require 'minitest/autorun'
require 'minitest-spec-context'

describe MonotonicTimer do

  it 'works' do
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
end

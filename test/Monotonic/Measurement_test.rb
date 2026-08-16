require_relative '../../lib/monotonic.rb'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotonic::Measurement do
  def measurement(nanoseconds, floor: 84, drift: nil)
    Monotonic::Measurement.new(nanoseconds, floor: floor, drift: drift)
  end

  describe "the unit" do
    it "is the largest which leaves a mantissa of at least one" do
      _(measurement(999).unit_name).must_equal('ns')
      _(measurement(1_000).unit_name).must_equal('us')
      _(measurement(1_265_625).unit_name).must_equal('ms')
      _(measurement(1_000_000_000).unit_name).must_equal('s')
    end

    it "stops at seconds, the ladder being powers of a thousand" do
      _(measurement(86_400_000_000_000).unit_name).must_equal('s')
    end

    it "is nanoseconds for nothing at all" do
      _(measurement(0).to_s).must_equal('0 ns')
    end
  end

  describe "the digits" do
    it "reach as far as the uncertainty does and no further" do
      _(measurement(1_265_625).to_s).must_equal('1.26562 ms')
    end

    it "are fewer upon a coarser instrument" do
      _(measurement(1_265_625, floor: 100_000).to_s).must_equal('1.27 ms')
    end

    it "are none where the interval is near the floor" do
      _(measurement(999).to_s).must_equal('999 ns')
    end

    it "are not capped, a day resolved to a hundred nanoseconds saying so" do
      _(measurement(86_400_000_000_000).to_s).must_equal('86400.00000000 s')
    end
  end

  describe "the uncertainty" do
    it "is the floor alone when no drift is supplied" do
      _(measurement(1_000_000).uncertainty).must_equal(84)
    end

    it "combines a drift in quadrature rather than by addition" do
      combined = measurement(1_000_000_000, drift: 1e-6).uncertainty
      _(combined).must_be_close_to(Math.sqrt(84**2 + 1_000**2), 0.01)
      _(combined).wont_be_close_to(84 + 1_000, 1)
    end

    it "takes digits away as it grows" do
      _(measurement(7_166_559_999, drift: 20e-6).decimals) \
        .must_be(:<, measurement(7_166_559_999).decimals)
    end

    it "comes from a Measurand, which owns the arithmetic" do
      _(measurement(1_000_000).measurand).must_be_instance_of(Measurand)
    end
  end

  describe "the floor" do
    it "may be a number" do
      _(measurement(1_000_000, floor: 84).floor).must_equal(84)
    end

    it "may be something callable, and is not called until doubt is asked about" do
      called = false
      subject = Monotonic::Measurement.new(1_000_000, floor: ->{called = true; 84})
      subject.to_i
      subject.to_duration
      _(called).must_equal(false)
      subject.uncertainty
      _(called).must_equal(true)
      _(subject.floor).must_equal(84)
    end
  end

  describe "comparison" do
    it "orders one measurement against another" do
      _(measurement(999)).must_be(:<, measurement(1_000))
      _([measurement(1_000), measurement(999)].sort.map(&:nanoseconds)).must_equal([999, 1_000])
    end

    it "is nil against a bare number, which has no unit" do
      _(measurement(999) <=> 999).must_be_nil
    end

    it "is therefore not equal to a bare number" do
      _(measurement(999) == 999).must_equal(false)
    end
  end

  describe "#to_duration" do
    it "hands the interval to duration.rb, whose business the units are" do
      _(measurement(1_500_000_000).to_duration).must_be_instance_of(Duration::Nanoseconds)
      _(measurement(1_500_000_000).to_duration.to_seconds.to_f).must_equal(1.5)
    end
  end

  describe "#to_i and #to_f" do
    it "both answer in nanoseconds, the measurement's own unit" do
      _(measurement(1_274_625).to_i).must_equal(1_274_625)
      _(measurement(1_274_625).to_f).must_equal(1_274_625.0)
    end

    it "agree with one another, and with #nanoseconds" do
      subject = measurement(1_274_625)
      _(subject.to_f).must_equal(subject.to_i.to_f)
      _(subject.to_i).must_equal(subject.nanoseconds)
    end
  end
end

# Monotonic/Measurement.rb
# Monotonic::Measurement

require 'duration.rb'
require 'measurand'

module Monotonic
  # An elapsed interval together with what it is worth.  The count alone says
  # nothing of how much of itself is real, so #to_s shows only as many digits as
  # the uncertainty supports.  Nothing is capped: a day resolved to a hundred
  # nanoseconds prints every figure it has, which looks absurd and is — the
  # absurdity being the mismatch between what the instrument resolves and what
  # was asked of it, and better seen than rounded away.
  #
  # The doubt is a Measurand's business and the unit is a Duration's; what is
  # left here is the ladder between them and the string at the end of it.
  class Measurement
    include Comparable

    # Powers of a thousand, and no further.  The scheme is a decimal-places one,
    # so minutes and hours have no place in it: 90s is plainer than 1.5min, and
    # a run of a day reads as 86400s rather than reaching for a unit which does
    # not divide by ten.
    UNITS = [[1, 'ns'], [1_000, 'us'], [1_000_000, 'ms'], [1_000_000_000, 's']]

    class << self
      # Built from a measurand rather than from a floor, for what comes back
      # from arithmetic: its uncertainty has been propagated rather than
      # measured, so it is neither an instrument's floor nor has a drift left to
      # apply a second time.
      def from(measurand)
        allocate.tap{|measurement| measurement.send(:build, measurand)}
      end
    end # class << self

    attr_reader :nanoseconds
    attr_reader :drift

    # The floor may be given as a number or as anything which answers to #call,
    # so that measuring it can wait until somebody asks about doubt.
    # Monotonic::Timer hands over its .floor method rather than its value, and a
    # caller which only wants a number never sets the thousand null measurements
    # going.
    def floor
      @floor = @floor.respond_to?(:call) ? @floor.call : @floor
    end

    # The floor is absolute and tells upon short intervals; drift is relative
    # and tells upon long ones, being the rate at which the clock's own
    # oscillator wanders.  Combining them is not addition — they are independent,
    # so they go in quadrature — which is why the arithmetic is Measurand's and
    # not done here.
    def measurand
      @measurand ||= (
        absolute = Measurand.new(@nanoseconds, floor)
        @drift ? absolute * Measurand.relative(1, @drift) : absolute
      )
    end

    def uncertainty
      measurand.uncertainty
    end

    # The arithmetic is Measurand's throughout — this only decides what may be
    # combined with what, and hands back the right kind of thing.  Two intervals
    # add and subtract to an interval, their uncertainties going in quadrature.
    def +(addend)
      self.class.from(measurand + as_measurand(addend, :add))
    end

    def -(subtrahend)
      self.class.from(measurand - as_measurand(subtrahend, :subtract))
    end

    # Scaled by a number it stays an interval, the uncertainty scaling with it.
    # Multiplied by another interval it would be time squared, which has no unit
    # here, so it is refused as Duration::Common refuses it.
    def *(multiplier)
      if interval?(multiplier)
        raise TypeError, "can't multiply #{self.class} by #{multiplier.class}: there is no unit of time squared"
      end
      self.class.from(measurand * multiplier)
    end

    # Divided by a number it stays an interval.  Divided by another interval the
    # units cancel and a Measurand is left — dimensionless, but still knowing how
    # well it is known, which is what a speedup or a rate is.
    def /(divisor)
      return measurand / divisor.measurand if divisor.respond_to?(:measurand)
      self.class.from(measurand / divisor)
    end

    def unit
      @unit ||= UNITS.reverse.find{|scale, _| @nanoseconds.abs >= scale} || UNITS.first
    end

    def scale
      unit.first
    end

    def unit_name
      unit.last
    end

    # The least significant digit worth showing is the one the uncertainty
    # reaches, which Measurand settles by the Particle Data Group convention and
    # reports as #place, a power of ten.  Rendering in a coarser unit moves it
    # along by however many tens that unit is worth.  A measurand with no
    # uncertainty has no last real digit, and answers nil.
    def decimals
      @decimals ||= (
        place = measurand.place
        place ? [Math.log10(scale) - place, 0].max.to_i : Math.log10(scale).to_i
      )
    end

    def to_duration
      Duration::Nanoseconds.new(@nanoseconds)
    end

    # Both answer in nanoseconds, this measurement's own unit, as
    # Duration::Minutes answers 5 rather than 300.  Every other unit comes from
    # #to_duration, which names the one it is asked for.  A number handed out
    # without its unit stated must at least always mean the same thing.
    def to_i
      @nanoseconds
    end

    def to_f
      @nanoseconds.to_f
    end

    def to_s
      format("%.#{decimals}f #{unit_name}", @nanoseconds.to_f / scale)
    end

    # Against another measurement only.  A bare number has no unit, and comparing
    # against one would have to assume which was meant, so nil is returned and ==
    # is false, as Duration::Common does.
    def <=>(other)
      return nil unless other.is_a?(Monotonic::Measurement)
      @nanoseconds <=> other.nanoseconds
    end

    def inspect
      "#<#{self.class} #{self} (#{measurand} ns)>"
    end

    private

    def initialize(nanoseconds, floor:, drift: nil)
      @nanoseconds = nanoseconds
      @floor = floor
      @drift = drift
    end

    # An interval is anything which knows its own doubt, or any duration, which
    # is exact.  A bare number is neither: it has no unit, so there is nothing to
    # add it to.
    def as_measurand(other, verb)
      return other.measurand if other.respond_to?(:measurand)
      return Measurand.new(other.to_nanoseconds.to_i) if other.respond_to?(:to_nanoseconds)
      raise TypeError, "can't #{verb} #{other.class} #{verb == :add ? "to" : "from"} #{self.class}: expected an interval or a duration"
    end

    def interval?(other)
      other.respond_to?(:measurand) || other.respond_to?(:to_nanoseconds)
    end

    def build(measurand)
      @nanoseconds = measurand.value.round
      @measurand = measurand
      @floor = measurand.uncertainty
    end
  end
end

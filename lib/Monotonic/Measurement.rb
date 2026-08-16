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
  end
end

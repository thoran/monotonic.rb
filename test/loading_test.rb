require_relative '../lib/monotonic.rb'

require 'minitest/autorun'
require 'minitest-spec-context'

# In its own process, since this one has loaded every file directly and so could
# not tell what requiring the gem alone would bring.
describe 'loading' do
  def ruby(source)
    lib = File.expand_path('../lib', __dir__)
    IO.popen(['ruby', "-I#{lib}", '-e', source], err: [:child, :out]){|io| io.read}.strip
  end

  it "defines both classes upon requiring the gem" do
    expect(ruby('require "monotonic.rb"; print [defined?(Monotonic::Time), defined?(Monotonic::Timer)].inspect')) \
      .must_equal('["constant", "constant"]')
  end

  it "defines the version too" do
    expect(ruby('require "monotonic.rb"; print Monotonic::VERSION')) \
      .must_equal(Monotonic::VERSION)
  end
end

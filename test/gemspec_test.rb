require_relative '../lib/monotonic.rb'

require 'minitest/autorun'
require 'minitest-spec-context'

describe 'monotonic.rb.gemspec' do
  let(:spec){Gem::Specification.load(File.expand_path('../monotonic.rb.gemspec', __dir__))}

  it "is a valid specification" do
    _(spec.validate).must_equal(true)
  end

  it "does not pin a date" do
    _(spec.date).must_equal(Gem::Specification.new.date)
  end

  it "takes its version from Monotonic::VERSION" do
    _(spec.version.to_s).must_equal(Monotonic::VERSION)
  end

  it "declares its runtime dependencies" do
    _(spec.runtime_dependencies.map(&:name).sort).must_equal(%w{duration.rb measurand sys-uptime})
  end

  # The minimum is what makes a dependency true, and naming the gem alone does
  # not say that it will work.  0.9.0 constrained measurand to >= 0.1.0, where
  # #place became public; #/ then became load-bearing at 0.1.2 without the
  # constraint following it, and Measurement#/ returned 0 against a version the
  # gemspec called satisfactory.
  it "declares a minimum version for each runtime dependency" do
    _(spec.runtime_dependencies.to_h{|dependency| [dependency.name, dependency.requirement.to_s]}) \
      .must_equal({'duration.rb' => '>= 0.4.0', 'measurand' => '>= 0.1.2', 'sys-uptime' => '>= 0'})
  end

  it "declares its development dependencies" do
    _(spec.development_dependencies.map(&:name).sort).must_equal(%w{minitest minitest-spec-context rake})
  end
end

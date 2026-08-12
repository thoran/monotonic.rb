require_relative '../../lib/monotonic.rb'

require 'minitest/autorun'
require 'minitest-spec-context'

describe Monotonic do
  describe "VERSION" do
    it "is a string" do
      _(Monotonic::VERSION).must_be_instance_of String
    end

    it "is three numbers separated by dots" do
      _(Monotonic::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../../CHANGELOG', __dir__))
      _(changelog[/^(\d+\.\d+\.\d+):/, 1]).must_equal Monotonic::VERSION
    end
  end
end

require_relative './lib/Monotonic/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'monotonic.rb'
  spec.version = Monotonic::VERSION

  spec.summary = "Monotonic timing made easy."
  spec.description = "Create accurate timings of excution in Ruby."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/monotonic.rb'
  spec.license = 'MIT'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.files = [
    'CHANGELOG',
    'Gemfile',
    Dir['lib/**/*.rb'],
    'monotonic.rb.gemspec',
    'Rakefile',
    'README.md',
    Dir['test/**/*.rb'],
  ].flatten

  spec.dependencies = %w{
    sys-uptime
  }

  spec.development_dependencies = %w{
    minitest
    minitest-spec-context
    rake
  }
end

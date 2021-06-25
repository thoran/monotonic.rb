require_relative './lib/Monotonic/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'monotonic.rb'

  spec.version = Monotonic::VERSION
  spec.date = '2021-06-23'

  spec.summary = "Monotonic timing made easy."
  spec.description = "Create accurate timings of excution in Ruby."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/monotonic.rb'
  spec.license = 'Ruby'

  spec.files = Dir['lib/**/*.rb']
  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency('sys-uptime')
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('minitest-spec-context')
end

require_relative './lib/Monotony/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'monotony.rb'

  spec.version = Monotony::VERSION
  spec.date = '2021-06-06'

  spec.summary = "Monotonic timing made easy."
  spec.description = "Create accurate timings of excution in Ruby reliably, er with monotony!"

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/monotony.rb'
  spec.license = 'Ruby'

  spec.files = Dir['lib/**/*.rb']
  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency('minitest')
  spec.add_development_dependency('minitest-spec-context')
end

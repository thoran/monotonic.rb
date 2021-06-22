# test/monotonic_test.rb

test_dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(test_dir) unless $LOAD_PATH.include?(test_dir)

tests = Dir[File.join(test_dir, 'Monotonic', '**', '*.rb')]
tests.each do |test|
  require test
end

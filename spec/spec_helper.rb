require 'simplecov'
require 'simplecov-console'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::Console]
)

SimpleCov.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  real_stdout = $stdout

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end

  config.before(:example, ignore_stdout: true) do
    $stdout = File.open(File::NULL, 'w')
  end

  config.after(:example, ignore_stdout: true) do
    $stdout = real_stdout
  end
end

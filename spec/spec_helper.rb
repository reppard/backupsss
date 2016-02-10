require 'simplecov'
require 'simplecov-console'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
]
SimpleCov.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  real_stdout = $stdout

  config.before(:example, ignore_stdout: true) do
    $stdout = File.open(File::NULL, 'w')
  end

  config.after(:example, ignore_stdout: true) do
    $stdout = real_stdout
  end
end

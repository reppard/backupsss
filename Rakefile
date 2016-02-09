require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
  task.fail_on_error = true
end

desc 'Run specs and rubocop before pushing'
task pre_commit: [:rubocop, :spec]

task default: :pre_commit

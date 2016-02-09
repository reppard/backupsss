guard :bundler do
  watch('backupsss.gemspec')
end

guard :rubocop do
  watch(/.+\.rb$/)
  watch(%r{(?:.+\/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^spec/(.+)/.+_spec\.rb})
  watch(%r{^lib/(.+)/(.+)\.rb}) { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
end

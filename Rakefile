require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*.rb'
end

task :default => :spec

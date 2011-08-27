require 'bundler/gem_tasks'
require 'rake'
require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts << "--colour --format specdoc --loadby mtime --reverse"
  t.spec_opts << "-r spec/spec_helper"
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => :spec

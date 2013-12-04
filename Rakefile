require 'rubygems/tasks'
Gem::Tasks.new

require 'fileutils'
task :clean do
  FileUtils.rm_rf %w[ pkg coverage doc ]
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end
task :default => :test

task(:coverage_env) { ENV['COVERAGE'] = "YES" }
Rake::TestTask.new(:coverage => :coverage_env) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard


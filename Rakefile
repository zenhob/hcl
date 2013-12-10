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

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard


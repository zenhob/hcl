require 'fileutils'
task :clean do
  FileUtils.rm_rf %w[ pkg coverage doc man/hcl.1 ]
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end
task :default => :test

require 'ronn'
task :man do
  print "Writing manual page..."
  File.open('man/hcl.1','w').tap do |man|
    man.write Ronn::Document.new('man/hcl.1.ronn').to_roff
  end
  puts "done."
end
task 'build:gem' => [:man]

require 'yard'
YARD::Rake::YardocTask.new
task :doc => [:yard, :man]

require 'rubygems/tasks'
Gem::Tasks.new


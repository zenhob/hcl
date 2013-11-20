$:.unshift(File.dirname(__FILE__) + '/lib')
require 'hcl'

desc 'install the hcl command'
task :install do
  system 'gem build hcl.gemspec'
  system "gem install hcl-#{HCl::VERSION}.gem"
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end
task :default => :test

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.options = %w[--files CHANGELOG]
end


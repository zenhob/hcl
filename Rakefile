$:.unshift(File.dirname(__FILE__) + '/lib')
require 'hcl'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

task :install do
  system 'gem build hcl.gemspec'
  system "gem install hcl-#{HCl::VERSION}.gem"
end


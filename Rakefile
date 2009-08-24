require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hcl"
    gem.summary = "Harvest timesheets from the command-line"
    gem.description = "HCl is a command-line client for manipulating Harvest time sheets."
    gem.email = "zack@opensourcery.com"
    gem.homepage = "http://github.com/zenhob/hcl"
    gem.authors = ["Zack Hobson"]
    gem.add_dependency "termios"
    gem.add_dependency "trollop", ">= 1.10.2"
    gem.add_dependency "chronic", ">= 0.2.3"
    gem.add_dependency "highline", ">= 1.5.1"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

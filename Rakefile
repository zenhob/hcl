require 'rubygems/tasks'
Gem::Tasks.new

# I am dumb and keep forgetting to update the bundle before releasing
task :update_bundle do
  system("bundle")
  system("git commit -am 'update gemfile.lock'")
end
task :release => [:update_bundle]

require 'fileutils'
task :clean do
  FileUtils.rm_rf %w[ pkg coverage doc man/hcl.1 ]
end

require 'rake/testtask'
ENV['EDITOR'] = ''
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end
task :default => :test

# process the README into a manual page using ronn
require 'ronn'
task 'man/hcl.1' do
  print "Writing manual page..."
  head, content = File.read('README.markdown').split("## SYNOPSIS\n")
  content.prepend <<-END
hcl(1) -- Track time with Harvest time sheets
=============================================

## SYNOPSIS
  END
  FileUtils.mkdir_p('man')
  File.write('man/hcl.1.ronn', content)
  File.open('man/hcl.1','w') do |man|
    man.write Ronn::Document.new('man/hcl.1.ronn').to_roff
  end
  puts "done."
end
task :build => 'man/hcl.1'

require 'yard'
YARD::Rake::YardocTask.new
task :doc => [:yard, :man]


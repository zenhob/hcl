require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb' 
begin
  Gem::Command.build_args = ARGV
rescue NoMethodError
end 
begin
  if RUBY_VERSION >= "2.0"
    Gem::DependencyInstaller.new.install "rubysl-test-unit"
  end
rescue
  exit(1)
end 

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'hcl'

Gem::Specification.new do |s|
  s.name = "hcl"
  s.version = HCl::VERSION

  s.authors = ["Zack Hobson"]
  s.email = "zack@zackhobson.com"
  s.description = "HCl is a command-line client for manipulating Harvest time sheets."
  s.executables = ["hcl"]
  s.files = %w[LICENSE Rakefile Gemfile bin/hcl bin/_hcl_completions man/hcl.1] + Dir['*.markdown'] +
    Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.homepage = "https://zenhob.github.io/hcl/"
  s.licenses = ["MIT"]
  s.summary = "Harvest timesheets from the command-line"

  s.add_runtime_dependency 'gem-man', '~>0.3.0'
  s.add_runtime_dependency 'trollop', '~>2.1.2'
  s.add_runtime_dependency 'chronic', '~>0.10.2'
  s.add_runtime_dependency 'highline', '~>2.0.3'
  s.add_runtime_dependency 'faraday', '~>0.17.0'
  s.add_runtime_dependency 'yajl-ruby', '~>1.4.1'
  s.add_runtime_dependency 'escape_utils', '~>1.2.1'
  s.add_runtime_dependency 'pry', '~>0.12.2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'yard', '~>0.9.20'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'minitest'
end

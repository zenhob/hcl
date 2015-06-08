source "https://rubygems.org"
gemspec

gem 'rubysl-abbrev'
gem 'rubysl-singleton'
gem 'rubysl-rexml'

group :development do
  gem 'ronn'
end

group :test do
  gem 'rubysl-coverage'
  gem 'rubinius-coverage'
  gem 'yajl-ruby'
end

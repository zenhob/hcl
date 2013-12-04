require 'bundler'

if ENV['COVERAGE'] == 'YES'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter do |source_file|
      source_file.lines.count < 15
    end
  end
end

require 'test/unit'
require 'mocha/setup'
require 'fileutils'
require 'fakeweb'

# override the default hcl dir
ENV['HCL_DIR'] = File.dirname(__FILE__)+"/dot_hcl"

require 'hcl'



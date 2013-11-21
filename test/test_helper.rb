require 'bundler'
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_filter do |source_file|
    source_file.lines.count < 15
  end
end

require 'test/unit'
require 'mocha/setup'

# override the default hcl dir
FileUtils.mkdir_p __dir__+"/dot_hcl"
ENV['HCL_DIR'] = __dir__+"/dot_hcl"

$:.unshift(__dir__ + '/../lib')
require 'hcl'



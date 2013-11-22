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
require 'fileutils'
require 'fakeweb'

# override the default hcl dir
FileUtils.mkdir_p __dir__+"/dot_hcl"
FileUtils.touch __dir__+"/dot_hcl/config.yml"
FileUtils.touch __dir__+"/dot_hcl/settings.yml"
ENV['HCL_DIR'] = __dir__+"/dot_hcl"

require 'hcl'



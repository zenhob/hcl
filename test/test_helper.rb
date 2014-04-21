require 'bundler'

begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/vendor/' # for travis-ci
    add_filter do |source_file|
      source_file.lines.count < 15
    end
    # source: https://travis-ci.org/zenhob/hcl
    minimum_coverage 80
  end
rescue LoadError
  $stderr.puts 'No test coverage tools found, skipping coverage check.'
end

# override the default hcl dir
ENV['HCL_DIR'] = File.dirname(__FILE__)+"/dot_hcl"

require 'hcl'
require 'minitest/autorun'
require 'mocha/setup'
require 'fileutils'
require 'faraday'
require 'byebug' if ENV['DEBUG']

# require test extensions/helpers
Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |ext| require ext }

class HCl::TestCase < MiniTest::Test
  attr_reader :http
  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
    @http = HCl::Net.new \
      'login' => 'bob',
      'password' => 'secret',
      'subdomain' => 'bobclock',
      'test_adapter' => @stubs
  end

  def register_uri method, path, data={}
    @stubs.send(method, path) { [200, {}, Yajl::Encoder.encode(data)] }
  end

  def register_status method, path, status_code
    @stubs.send(method, path) { [status_code.to_i, {}, ''] }
  end

  def teardown
    @stubs.verify_stubbed_calls
  end
end



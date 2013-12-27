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
    minimum_coverage case RUBY_ENGINE
      when "rbx" then 84
      when "jruby" then 73
      else 78
    end
  end
rescue LoadError => e
  $stderr.puts 'No test coverage tools found, skipping coverage check.'
end

# override the default hcl dir
ENV['HCL_DIR'] = File.dirname(__FILE__)+"/dot_hcl"

require 'hcl'
require 'minitest/autorun'
require 'mocha/setup'
require 'fileutils'
require 'fakeweb'

# require test extensions/helpers
Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |ext| require ext }

class HCl::TestCase < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    HCl::Net.configure \
      'login' => 'bob',
      'password' => 'secret',
      'subdomain' => 'bobclock',
      'ssl' => true
  end
  def teardown
    FakeWeb.clean_registry
  end
end



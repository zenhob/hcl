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

module IgnoreStderr
  def before_setup
    super
    $stderr = @stderr = StringIO.new
    $stdout = @stdout = StringIO.new
  end
  def after_teardown
    super
    $stderr = STDERR
    $stdout = STDOUT
  end
end
class HCl::TestCase < MiniTest::Unit::TestCase
  include IgnoreStderr
end



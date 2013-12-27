module CaptureOutput
  def before_setup
    super
    @stderr = StringIO.new
    @stdout = StringIO.new
    return if ENV['VERBOSE']
    $stderr = @stderr
    $stdout = @stdout
  end
  def after_teardown
    super
    return if ENV['VERBOSE']
    $stderr = STDERR
    $stdout = STDOUT
  end
  def error_output
    @stderr.string
  end
  def standard_output
    @stdout.string
  end
end
class MiniTest::Unit::TestCase
  include CaptureOutput
end



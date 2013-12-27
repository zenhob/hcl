module CaptureOutput
  def before_setup
    super
    @stderr = StringIO.new
    @stdout = StringIO.new
    $stderr = @stderr
    $stdout = @stdout
  end
  def after_teardown
    super
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



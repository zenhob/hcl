module CaptureOutput
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
  def error_output
    @stderr.string
  end
  def standard_output
    @stdout.string
  end
end
class HCl::TestCase < MiniTest::Unit::TestCase
  include CaptureOutput
end



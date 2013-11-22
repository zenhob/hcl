require 'test_helper'
class AppTest < Test::Unit::TestCase

  def setup
    # touch config to avoid triggering manual config
    FileUtils.mkdir_p HCl::App::HCL_DIR
    FileUtils.touch File.join(HCl::App::HCL_DIR, "config.yml")
  end

  def test_commands
    app = HCl::App.new
    assert HCl::Commands.instance_methods.all? { |c| app.command? c  }, 'all methods are commands'
  end

  def test_command_show
    HCl::DayEntry.expects(:all).returns [HCl::DayEntry.new(
      hours:'2.06', notes:'hi world', project:'App'
    )]
    HCl::App.command 'show'
  end

  def test_command_retry_on_throttle
    app = HCl::App.new
    throttled = states('throttled').starts_as(false)
    app.expects(:show).
      raises(HCl::TimesheetResource::ThrottleFailure, stub(headers:{'Retry-After' => 42})).
      then(throttled.is(true))
    app.expects(:sleep).with(47).when(throttled.is(true))
    app.expects(:show).when(throttled.is(true))
    app.process_args('show').run
  end
end

require 'test_helper'
class AppTest < HCl::TestCase

  def setup
    super
    # touch config to avoid triggering manual config
    FileUtils.mkdir_p HCl::App::HCL_DIR
    FileUtils.touch File.join(HCl::App::HCL_DIR, "config.yml")
  end

  def test_commands
    app = HCl::App.new
    assert HCl::Commands.instance_methods.all? { |c| app.command? c  }, 'all methods are commands'
  end

  def test_command_show
    HCl::DayEntry.expects(:daily).returns [HCl::DayEntry.new(
      hours:'2.06', notes:'hi world', project:'App'
    )]
    HCl::App.command 'show'
  end

  def test_command_retry_on_throttle
    app = HCl::App.new
    throttled = states('throttled').starts_as(false)
    app.expects(:show).
      raises(HCl::HarvestMiddleware::ThrottleFailure, {response_headers:{'retry-after' => 42}}).
      then(throttled.is(true))
    app.expects(:sleep).with(47).when(throttled.is(true))
    app.expects(:show).when(throttled.is(true))
    app.process_args('show').run
  end

  def test_generic_failure
    app = HCl::App.new
    app.expects(:show).raises(RuntimeError)
    app.expects(:exit).with(1)
    app.process_args('show').run
  end

  def test_socket_error
    app = HCl::App.new
    app.expects(:show).raises(Faraday::Error)
    app.expects(:exit).with(1)
    app.process_args('show').run
    assert_match(/connection failed/i, error_output)
  end

  def test_configure_on_auth_failure
    app = HCl::App.new
    configured = states('configured').starts_as(false)
    app.expects(:show).raises(HCl::HarvestMiddleware::AuthFailure).when(configured.is(false))
    app.expects(:ask).returns('xxx').times(3).when(configured.is(false))
    app.expects(:write_config).then(configured.is(true))
    app.expects(:show).when(configured.is(true))
    app.process_args('show').run
    assert_match(/unable to authenticate/i, error_output)
  end

  def test_api_failure
    app = HCl::App.new
    app.expects(:show).raises(HCl::HarvestMiddleware::Failure)
    app.expects(:exit).with(1)
    app.process_args('show').run
    assert_match(/API failure/i, error_output)
  end

end

require 'test_helper'
class AppTest < Test::Unit::TestCase

  def test_commands
    app = HCl::App.new
    assert HCl::Commands.instance_methods.all? { |c| app.command? c  }, 'all methods are commands'
  end
end

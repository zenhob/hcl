require 'test_helper'
class AppTest < Test::Unit::TestCase

  def test_commands
    app = HCl::App.new
    assert HCl::Commands.instance_methods.all? { |c| app.command? c  }, 'all methods are commands'
  end

  def test_command_show
    HCl::DayEntry.expects(:all).returns([HCl::DayEntry.new({
      hours:'2.06',
      notes: 'hi world',
      project: 'App'
    })])
    HCl::App.command 'show'
  end
end

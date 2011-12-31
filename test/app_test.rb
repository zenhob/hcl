require 'test_helper'
class AppTest < Test::Unit::TestCase

  should "permit commands from the HCl::Commands module" do
    app = HCl::App.new
    assert HCl::Commands.instance_methods.all? { |c| app.command? c  }, 'all methods are commands'
  end
end

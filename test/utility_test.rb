require 'test_helper'

class UtilityTest < Test::Unit::TestCase
  include HCl::Utility

  should "convert decimal input when converting time2float" do
    assert_equal 2.5, time2float("2.5")
  end

  should "convert HH:MM input when converting time2float" do
    assert_equal 2.5, time2float("2:30")
  end

  should "assume decimal input when converting time2float" do
    assert_equal 2.0, time2float("2")
  end
end

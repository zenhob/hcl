require 'test_helper'

class UtilityTest < MiniTest::Unit::TestCase
  include HCl::Utility

  def test_time2float_decimal
    assert_equal 2.5, time2float("2.5")
  end

  def test_time2float_hhmm
    assert_equal 2.5, time2float("2:30")
  end

  def test_time2float_assume_decimal
    assert_equal 2.0, time2float("2")
  end
end

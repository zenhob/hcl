require 'test_helper'

class UtilityTest < HCl::TestCase
  include HCl::Utility

  def test_get_task_ids
    @settings = {'task.taco'=>'123 456'}
    assert_equal ['123', '456'], get_task_ids('taco', [])
  end

  def test_get_ident_with_symbol
    assert_equal 'taco', get_ident(%w[ +:25 @taco makin tacos ])
  end

  def test_get_ident_without_symbol
    assert_equal 'burrito', get_ident(%w[ burrito +:32 makin burritos ])
  end

  def test_get_starting_time_minutes
    assert_equal 0.25, get_starting_time(%w[ @taco +:15 makin tacos ])
  end

  def test_get_starting_time_decimal
    assert_equal 0.25, get_starting_time(%w[ @taco +.25 makin tacos ])
  end

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

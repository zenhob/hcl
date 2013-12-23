require 'test_helper'

class DayEntryTest < HCl::TestCase
  def test_cancel_success
    entry = HCl::DayEntry.new(id:123)
    HCl::DayEntry.expects(:delete)
    assert entry.cancel
  end

  def test_cancel_failure
    entry = HCl::DayEntry.new(id:123)
    HCl::DayEntry.expects(:delete).raises(HCl::TimesheetResource::Failure)
    assert !entry.cancel
  end

  def test_to_s
    entry = HCl::DayEntry.new \
      hours: '1.2', client: 'Taco Town', project:'Pizza Taco', task:'Preparation'
    assert_equal "Taco Town - Pizza Taco - Preparation (1:12)", entry.to_s
  end

  def test_append_note
    entry = HCl::DayEntry.new(:id => '1', :notes => 'yourmom.', :hours => '1.0')
    HCl::DayEntry.stubs(:post)
    entry.append_note('hi world')
    assert_equal "yourmom.\nhi world", entry.notes
  end

  def test_append_note_to_empty
    entry = HCl::DayEntry.new(:id => '1', :notes => nil, :hours => '1.0')
    HCl::DayEntry.stubs(:post)
    entry.append_note('hi world')
    assert_equal 'hi world', entry.notes
  end
end

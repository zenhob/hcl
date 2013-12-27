require 'test_helper'

class DayEntryTest < HCl::TestCase
  def test_all_today_empty
    FakeWeb.register_uri(:get, %r{/daily$}, body: Yajl::Encoder.encode({projects:[],day_entries:[]}))
    assert HCl::DayEntry.all.empty?
  end

  def test_all_today
    FakeWeb.register_uri(:get, %r{/daily$}, body: Yajl::Encoder.encode({
      projects:[], day_entries:[{id:1,note:'hi'}]}))
    assert_equal 'hi', HCl::DayEntry.all.first.note
  end

  def test_all_with_date
    FakeWeb.register_uri(:get, %r{/daily/013/2013$}, body: Yajl::Encoder.encode({
      projects:[], day_entries:[{id:1,note:'hi'}]}))
    assert_equal 'hi', HCl::DayEntry.all(Date.civil(2013,1,13)).first.note
  end

  def test_toggle
    entry = HCl::DayEntry.new(id:123)
    FakeWeb.register_uri(:get, %r{/daily/timer/123$}, body:'hi'.inspect)
    entry.toggle
  end
  def test_cancel_success
    entry = HCl::DayEntry.new(id:123)
    HCl::DayEntry.expects(:delete)
    assert entry.cancel
  end

  def test_cancel_failure
    entry = HCl::DayEntry.new(id:123)
    HCl::DayEntry.expects(:delete).raises(HCl::HarvestMiddleware::Failure)
    assert !entry.cancel
  end

  def test_to_s
    entry = HCl::DayEntry.new \
      hours: '1.2', client: 'Taco Town', project:'Pizza Taco', task:'Preparation'
    assert_equal "Taco Town - Pizza Taco - Preparation (1:12)", entry.to_s
  end

  def test_append_note
    entry = HCl::DayEntry.new(:id => '1', :notes => 'yourmom.', :hours => '1.0')
    HCl::Net.stubs(:post)
    entry.append_note('hi world')
    assert_equal "yourmom.\nhi world", entry.notes
  end

  def test_append_note_to_empty
    entry = HCl::DayEntry.new(:id => '1', :notes => nil, :hours => '1.0')
    HCl::Net.stubs(:post)
    entry.append_note('hi world')
    assert_equal 'hi world', entry.notes
  end
end
